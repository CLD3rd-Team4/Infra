# Lambda 실행 역할
resource "aws_iam_role" "lambda_role" {
  name = "${var.common_prefix}db-alert-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# Lambda 기본 실행 정책 연결
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda 함수 코드 압축
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/slack_notifier.py"
  output_path = "${path.module}/slack_notifier.zip"
}

# Lambda 함수들 생성 (각 DB 서비스별)
resource "aws_lambda_function" "db_alert_notifier" {
  for_each = var.db_services

  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.common_prefix}${each.key}-db-alert"
  role            = aws_iam_role.lambda_role.arn
  handler         = "slack_notifier.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.9"
  timeout         = 30

  environment {
    variables = {
      "${upper(each.key)}_WEBHOOK_URL" = each.value.webhook_url
      SERVICE_NAME = each.key
    }
  }

  tags = merge(var.common_tags, {
    Name    = "${var.common_prefix}${each.key}-db-alert"
    Service = each.key
  })
}

# SNS Topic Subscription (Lambda 모듈에서 생성)
resource "aws_sns_topic_subscription" "lambda_subscription" {
  for_each = var.db_services
  
  topic_arn = var.sns_topic_arns[each.key]
  protocol  = "lambda"
  endpoint  = aws_lambda_function.db_alert_notifier[each.key].arn
}

# SNS가 Lambda를 호출할 수 있도록 권한 부여
resource "aws_lambda_permission" "allow_sns" {
  for_each = var.db_services

  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.db_alert_notifier[each.key].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arns[each.key]
}
