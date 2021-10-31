variable "region" {
  description = "The AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "stack_prefix" {
  description = "Prefix for resources"
  type        = string
  default     = "tf-test"
}

variable "availability_zones" {
  description = "AWS availability zones."
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "vpc_cidr" {
  description = "A /16 CIDR for the VPC"
  type        = string
  default     = "172.17.0.0/16"
}


