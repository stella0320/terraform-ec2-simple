variable "vpc_cidr" {
  default = "10.0.0.0/18"
  description = "The CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
  description = "The CIDR block for the public subnet"
}

variable "availability_zone" {
  default = "ap-northeast-1a"
  description = "The availability zone for the public subnet"
}

variable "ami_id" {
  default = "ami-0aec5ae807cea9ce0"
  description = "The AMI ID for the EC2 instance"
}

variable "instance_type" {
  default = "t2.nano"
  description = "The instance type for the EC2 instance"
}

variable "discord_webhook_url" {
  description = "Discord webhook URL for notifications"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_discord_notifications" {
  description = "Enable Discord notifications after deployment"
  type        = bool
  default     = false
}

# --------------------------
# VPC
# --------------------------
resource "aws_vpc" "aws_og_vpc" {
  cidr_block           = var.vpc_cidr

  tags = {
    Name = "aws-og-vpc"
  }
}

# --------------------------
# Internet Gateway
# --------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.aws_og_vpc.id

  tags = {
    Name = "aws-og-igw"
  }
}

# --------------------------
# Public Subnet
# --------------------------
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.aws_og_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "aws-og-public-subnet"
  }
}

# --------------------------
# Route Table (public)
# --------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.aws_og_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "aws-og-public-rt"
  }
}

# # --------------------------
# # Route table association
# --------------------------
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# --------------------------
# key Pair
# --------------------------

resource "aws_key_pair" "aws_og_key" {
  key_name   = "aws-og-key"
  public_key = file("C:\\Users\\jud40\\.ssh\\id_rsa.pub")
}

# --------------------------
# Security Group
# --------------------------
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  my_cidr = "${trimspace(data.http.my_ip.response_body)}/32"
}


resource "aws_security_group" "aws_og_sg" {
  name        = "aws-og-sg"
  description = "Allow SSH + HTTP"
  vpc_id      = aws_vpc.aws_og_vpc.id

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
    cidr_blocks = [local.my_cidr] # 例如 123.13.55.88/32
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


# --------------------------
# EC2 Instance
# --------------------------
resource "aws_instance" "aws_og_public_ec2" {
  ami          = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.aws_og_sg.id]
  key_name                    = aws_key_pair.aws_og_key.key_name
  associate_public_ip_address = true  # public subnet 要加這個！

  tags = {
    Name = "aws-og-public-ec2"
  }
}



output "ec2_public_ip" {
  value = aws_instance.aws_og_public_ec2.public_ip
}

output "ssh_command" {
  value = "ssh ubuntu@${aws_instance.aws_og_public_ec2.public_ip}"
}

# --------------------------
# Discord Notification
# --------------------------
resource "null_resource" "discord_notification" {
  count = var.enable_discord_notifications && var.discord_webhook_url != "" ? 1 : 0

  triggers = {
    ec2_id = aws_instance.aws_og_public_ec2.id
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      curl -H "Content-Type: application/json" \
        -d "{\"embeds\":[{\"title\":\"🚀 AWS Infrastructure Deployed\",\"color\":3066993,\"fields\":[{\"name\":\"EC2 Public IP\",\"value\":\"${aws_instance.aws_og_public_ec2.public_ip}\",\"inline\":true},{\"name\":\"Instance Type\",\"value\":\"${var.instance_type}\",\"inline\":true},{\"name\":\"Region\",\"value\":\"ap-northeast-1\",\"inline\":true},{\"name\":\"VPC CIDR\",\"value\":\"${var.vpc_cidr}\",\"inline\":true},{\"name\":\"SSH Command\",\"value\":\"\`\`\`ssh ubuntu@${aws_instance.aws_og_public_ec2.public_ip}\`\`\`\",\"inline\":false}],\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\"}]}" \
        "${var.discord_webhook_url}"
    EOT
    interpreter = ["bash", "-c"]
  }

  depends_on = [aws_instance.aws_og_public_ec2]
}