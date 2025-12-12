variable "environment" {
  description = "Environment name: dev, stage, prod"
  type        = string
}

variable "vpc_cidr" {
  default     = "10.0.0.0/18"
  description = "The CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  default     = "10.0.1.0/24"
  description = "The CIDR block for the public subnet"
}

variable "availability_zone" {
  default     = "ap-northeast-1a"
  description = "The availability zone for the public subnet"
}

variable "ami_id" {
  default     = "ami-0aec5ae807cea9ce0"
  description = "The AMI ID for the EC2 instance"
}

variable "instance_type" {
  default     = "t2.nano"
  description = "The instance type for the EC2 instance"
}

variable "key_name" {
  default     = "aws-og-key"
  description = "The name of the key pair"
}

variable "subnet_id" {
  description = "The subnet ID where the EC2 instance will be launched"
}
variable "vpc_security_group_ids" {
  description = "The security group IDs for the EC2 instance"
}