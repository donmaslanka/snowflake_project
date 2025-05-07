provider "aws" {
  region = var.region
}

# VPC + Subnets
resource "aws_vpc" "tuai" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${var.name}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tuai.id
  tags   = var.tags
}

resource "aws_subnet" "public" {
  for_each                  = toset(var.public_subnet_cidrs)
  vpc_id                    = aws_vpc.tuai.id
  cidr_block                = each.key
  map_public_ip_on_launch   = true
  availability_zone         = "${var.region}a"
  tags                      = var.tags
}

resource "aws_subnet" "private" {
  for_each          = toset(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.tuai.id
  cidr_block        = each.key
  availability_zone = "${var.region}a"
  tags              = var.tags
}

# VPN Components
resource "aws_customer_gateway" "cgw" {
  bgp_asn    = var.bgp_asn
  ip_address = var.customer_gateway_ip
  type       = "ipsec.1"
  tags       = var.tags
}

resource "aws_vpn_gateway" "vgw" {
  vpc_id = aws_vpc.tuai.id
  tags   = var.tags
}

resource "aws_vpn_connection" "vpn" {
  vpn_gateway_id      = aws_vpn_gateway.vgw.id
  customer_gateway_id = aws_customer_gateway.cgw.id
  type                = "ipsec.1"
  static_routes_only  = true
  tags                = var.tags
}

resource "aws_vpn_connection_route" "routes" {
  for_each               = toset(var.vpn_destination_cidrs)
  vpn_connection_id      = aws_vpn_connection.vpn.id
  destination_cidr_block = each.key
}

# Private Routing
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.tuai.id
  tags   = var.tags
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "vpn_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_vpn_gateway.vgw.id
}

# Flow Logs (CloudWatch)
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc/${var.name}/flow-logs"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "flow_logs" {
  count      = var.enable_flow_logs ? 1 : 0
  role       = aws_iam_role.flow_logs[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_flow_log" "vpc" {
  count                = var.enable_flow_logs ? 1 : 0
  log_destination_type = "cloud-watch-logs"
  log_group_name       = aws_cloudwatch_log_group.vpc_flow_logs[0].name
  iam_role_arn         = aws_iam_role.flow_logs[0].arn
  traffic_type         = var.flow_log_traffic_type
  vpc_id               = aws_vpc.tuai.id
  tags                 = var.tags
}