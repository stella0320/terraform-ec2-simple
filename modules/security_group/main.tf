# --------------------------
# Security Group
# --------------------------
# data "http" "my_ip" {
#   url = "https://checkip.amazonaws.com"
# }

# locals {
#   my_cidr = "${trimspace(data.http.my_ip.response_body)}/32"
# }


resource "aws_security_group" "public" {
  name        = "aws-og-sg"
  description = "Allow SSH + HTTP"
  vpc_id      = var.vpc_id

  # SSH (anywhere)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP (only your IP)
  ingress {
    description = "HTTP from my IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] # 例如 123.13.55.88/32
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-og-sg"
  }
}