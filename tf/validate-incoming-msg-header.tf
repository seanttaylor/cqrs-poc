data "archive_file" "lambda_validate_incoming_msg_header" {
  type = "zip"

  source_dir  = "../lib/lambda/validate-incoming-msg-header"
  output_path = "../dist/validate-incoming-msg-header.zip"
}

resource "aws_s3_object" "lambda_validate_incoming_msg_header" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "validate-incoming-msg-header.zip"
  source = data.archive_file.lambda_validate_incoming_msg_header.output_path

  etag = filemd5(data.archive_file.lambda_validate_incoming_msg_header.output_path)
}