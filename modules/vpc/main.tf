# --------------------------
# VPC
# --------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr

  tags = {
    Name = "aws-og-vpc"
  }
}

# --------------------------
# Internet Gateway
# --------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "aws-og-igw"
  }
}

# --------------------------
# Public Subnet
# --------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
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
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "aws-og-public-rt"
  }
}

# # --------------------------
# # Route table association
# --------------------------
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
