output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpn_connection_id" {
  value = aws_vpn_connection.vpn.id
}

output "vpn_gateway_id" {
  value = aws_vpn_gateway.vgw.id
}

output "flow_log_group" {
  value       = aws_cloudwatch_log_group.vpc_flow_logs[*].name
  description = "CloudWatch Log Group for VPC Flow Logs"
}