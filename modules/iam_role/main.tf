resource "aws_iam_role" "public" {
  name              = var.name
  assume_role_policy = var.assume_role_policy
  tags = var.tags
}


resource "aws_iam_role_policy_attachment" "public" {
  for_each = toset(var.lambda_policies)
  role = aws_iam_role.public.name
  policy_arn = each.value
}