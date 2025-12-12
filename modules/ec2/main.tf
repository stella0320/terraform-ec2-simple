# --------------------------
# EC2 Instance
# --------------------------
resource "aws_instance" "public" {
  ami          = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = true  # public subnet 要加這個！

  tags = {
    Name = "aws-og-public-ec2"
  }
}


