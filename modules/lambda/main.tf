# lambda
resource "aws_lambda_function" "public" {
    function_name = var.function_name
    filename      = var.filename
    handler       = var.handler
    runtime       = var.runtime
    role          = var.iam_role_arn
    timeout = var.timeout
    source_code_hash = filebase64sha256("modules/lambda/lambda_function.zip") # 讓terraform可以偵測檔案變更
    environment {
      variables = var.environment_variables
    }
    tags = var.tags
}

resource "aws_lambda_permission" "public" {
  statement_id  = var.statement_id
  action        = var.action
  function_name = aws_lambda_function.public.function_name
  principal     = var.principal
  source_arn    = var.resource_arn
}