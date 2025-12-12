variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
}
variable "subnet_id" {
  description = "The subnet ID where the EC2 instance will be launched"
}
variable "vpc_security_group_ids" {
  type = list(string)
  description = "The security group IDs for the EC2 instance"
}

variable "key_name" {
  description = "The name of the key pair"
}