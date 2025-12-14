data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "public" {
  bucket = "${var.bucket_name}-${data.aws_caller_identity.current.account_id}"
  tags = var.tags
}
