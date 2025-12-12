bucket         = "aws-og-terraform-state"
key            = "dev/terraform.tfstate"
region         = "ap-northeast-1"
dynamodb_table = "terraform-lock"
encrypt        = true