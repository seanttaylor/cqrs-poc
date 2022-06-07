################## hello_world LAMBDA CONFIGURATION ###################

resource "aws_lambda_function" "hello_world" {
  function_name = "hello-world-${local.git_commit_sha}"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_hello_world.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.lambda_hello_world.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "hello_world" {
  name = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

################## validate_incoming_msg_header LAMBDA CONFIGURATION ###################

resource "aws_lambda_function" "validate_incoming_msg_header" {
  function_name = "validate-incoming-msg-header-${local.git_commit_sha}"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_validate_incoming_msg_header.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.lambda_validate_incoming_msg_header.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "validate_incoming_msg_header" {
  name = "/aws/lambda/${aws_lambda_function.validate_incoming_msg_header.function_name}"

  retention_in_days = 30
}

################## enrich_incoming_msg LAMBDA CONFIGURATION ###################

resource "aws_lambda_function" "enrich_incoming_msg" {
  function_name = "enrich-incoming-msg-${local.git_commit_sha}"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_enrich_incoming_msg.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.lambda_enrich_incoming_msg.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "enrich_incoming_msg" {
  name = "/aws/lambda/${aws_lambda_function.enrich_incoming_msg.function_name}"

  retention_in_days = 30
}

################## route_incoming_msg LAMBDA CONFIGURATION ###################

resource "aws_lambda_function" "route_incoming_msg" {
  function_name = "route-incoming-msg-${local.git_commit_sha}"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_route_incoming_msg.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.lambda_route_incoming_msg.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "route_incoming_msg" {
  name = "/aws/lambda/${aws_lambda_function.route_incoming_msg.function_name}"

  retention_in_days = 30
}

################## create_db_digest_record LAMBDA CONFIGURATION ###################

resource "aws_lambda_function" "create_db_digest_record" {
  function_name = "create-db-digest-record${local.git_commit_sha}"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_create_db_digest_record.key

  runtime = "nodejs16.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.lambda_create_db_digest_record.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "create_db_digest_record" {
  name = "/aws/lambda/${aws_lambda_function.create_db_digest_record.function_name}"

  retention_in_days = 30
}