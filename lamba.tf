resource "aws_lambda_function" "refresh" {
  function_name    = local.lambda_base_name
  description      = "Tailscale refresh lamba"
  handler          = "lambda.handler"
  role             = aws_iam_role.refresh_lambda.arn
  runtime          = "python3.9"
  memory_size      = 128
  timeout          = 10
  architectures    = ["arm64"]
  filename         = local.lambda_package
  source_code_hash = data.archive_file.refresh_lambda_function.output_base64sha256

  environment {
    variables = {
      AUTO_SCALING_GROUP_NAME = aws_autoscaling_group.this.name
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_events" {
  statement_id  = "AllowCloudWatchEventsInvokeFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.refresh.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule.arn
}
