module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = "hello-world-table"
  hash_key = "id"

  attributes = [
    {
      name = "id"
      type = "N"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "staging"
  }
}

data "aws_iam_policy_document" "lambda_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]
    resources = [module.dynamodb_table.dynamodb_table_arn]
  }
}

module "helloworld-lambda" {
  source = "terraform-aws-modules/lambda/aws"

  ######################
  # Lambda Package
  ######################
  runtime                     = "dotnet6"
  function_name               = "HelloWorld"
  description                 = "HelloWorld Function"
  handler                     = "HelloWorld::HelloWorld.Function::FunctionHandler"
  local_existing_package      = "../../functions/HelloWorld.zip"

  publish                     = true
  create_package              = false
  ignore_source_code_hash     = false
  create_lambda_function_url  = true

  ######################
  # Roles
  ######################
  attach_policy_jsons         = true
  policy_jsons                = [
    data.aws_iam_policy_document.lambda_policy_document.json
  ]
  number_of_policy_jsons = 1
}