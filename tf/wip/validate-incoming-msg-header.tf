data "archive_file" "lambda_validate_incoming_msg_header" {
  type = "zip"

  source_dir  = "../../lib/lambda/validate-incoming-msg-header"
  output_path = "../../dist/validate-incoming-msg-header.zip"
}

resource "aws_s3_object" "lambda_validate_incoming_msg_header" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "ice-cream-pipeline/validate-incoming-msg-header.zip"
  source = data.archive_file.lambda_validate_incoming_msg_header.output_path

  etag = filemd5(data.archive_file.lambda_validate_incoming_msg_header.output_path)
}

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
