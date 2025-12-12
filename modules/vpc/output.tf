output "public_subnet_id" {
  value = aws_subnet.public.id
  description = "The ID of the public subnet"
}

output "vpc_id" {
  value = aws_vpc.this.id
  description = "The ID of the VPC"
}