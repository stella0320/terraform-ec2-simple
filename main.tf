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
  vpc_sg_name = "aws-og-sg"
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
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.3"
    }
  }
}

#--------------------------
# week2
#--------------------------


#--------------------------
# S3 Bucket
#--------------------------
module "s3_bucket_receipts" {
  source      = "./modules/s3"
  bucket_name = "receipts-${var.environment}"
  tags = {
    "env"  = var.environment
    "version" = "aws-og-week2"
  }

}

# 在 bucket上 加上 events notification

resource "aws_s3_bucket_notification" "public" {
  bucket = module.s3_bucket_receipts.s3_bucket_id
  lambda_function {
    lambda_function_arn = module.s3_notify_lambda_function.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".png"
  }

  depends_on = [module.s3_notify_lambda_function]
}

#--------------------------
# IAM Role for Lambda : 定義誰可以使用這個角色，建立角色後下一步是建立政策(permission)附加到這個角色上
#--------------------------
module "lambda_iam_role" {
  source = "./modules/iam_role"
  name = "lambda-iam-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  lambda_policies = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
                     "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  tags = {
    "env"  = var.environment
    "version" = "aws-og-week2"
  }
}

#--------------------------
# Lambda Function
#--------------------------

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/modules/lambda/lambda_function"
  output_path = "${path.module}/modules/lambda/lambda_function.zip"
}

module "s3_notify_lambda_function" {
  source = "./modules/lambda"
  function_name = "s3-notify-function-${var.environment}"
  filename = data.archive_file.lambda_zip.output_path
  handler = "s3_upload_trigger_function.lambda_handler"
  runtime = "python3.14"
  iam_role_arn = module.lambda_iam_role.iam_role_arn
  s3_bucket_arn = module.s3_bucket_receipts.s3_bucket_arn
 

  environment_variables = {
      DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1307026207325552781/yiAZaCxjkc_z8VQ4NhXMYYYZ0JaHudsy8qB1PzHT3uk7vncEghXEbBigSDoRrOPoC6kT"
  }

  # policy permission 允許s3觸發lambda
  statement_id = "AllowExecutionFromS3"
  action = "lambda:InvokeFunction"
  principal = "s3.amazonaws.com"
  resource_arn = module.s3_bucket_receipts.s3_bucket_arn
  tags = {
    "env"  = var.environment
    "version" = "aws-og-week2"
  }
}

# #--------------------------
# # lambda security group
# #--------------------------

# module "lambda_security_group" {
#   source = "./modules/security_group"
#   vpc_sg_name = "lambda-sg-${var.environment}"
#   vpc_id = module.vpc.vpc_id
#   my_ip  = local.my_cidr
# }
