variable "name" {
  description = "Prefix for naming resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

variable "customer_gateway_ip" {
  description = "On-prem VPN public IP"
  type        = string
}

variable "bgp_asn" {
  description = "Customer BGP ASN"
  type        = number
  default     = 65000
}

variable "vpn_destination_cidrs" {
  description = "CIDRs routed through VPN"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "Retention days for Flow Logs"
  type        = number
  default     = 30
}

variable "flow_log_traffic_type" {
  description = "Flow log traffic type: ALL | ACCEPT | REJECT"
  type        = string
  default     = "ALL"
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}