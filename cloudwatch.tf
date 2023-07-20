resource "aws_cloudwatch_event_rule" "rule" {
  name                = local.lambda_base_name
  schedule_expression = var.refresh_lambda_interval
}

resource "aws_cloudwatch_event_target" "refresh_lambda" {
  rule = aws_cloudwatch_event_rule.rule.id
  arn  = aws_lambda_function.refresh.arn
}
