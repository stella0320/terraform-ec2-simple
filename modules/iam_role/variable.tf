variable "name" {
  description = "iam role name"
}

variable "assume_role_policy" {
  description = "The policy that grants an entity permission to assume the role"
  type = string
}

variable "tags" {
  description = "Tags"
  type = map(string)
}

variable "lambda_policies" {
  type = list(string)
  description = "The ARN of the policy you want to attach"
}