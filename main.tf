provider "aws" {
  region = "ap-northeast-1"
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  my_cidr = "${trimspace(data.http.my_ip.response_body)}/32"
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
}

module "key_pair" {
  source        = "./modules/key_pair"
  key_pair_path = "C:/Users/jud40/.ssh/id_rsa.pub"
  key_name      = var.key_name
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
  my_ip  = local.my_cidr
}


module "ec2" {
  source                 = "./modules/ec2"
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = module.vpc.public_subnet_id
  vpc_security_group_ids = [module.security_group.aws_og_sg_id]
  key_name               = module.key_pair.key_name
}

terraform {
  backend "s3" {}
}




