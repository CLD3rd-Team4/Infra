resource "aws_dynamodb_table" "this" {
  # --- 네이밍 ---
  name           = "${var.name_prefix}${var.table_name}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "restaurant_id"
  range_key      = "review_id"

  attribute {
    name = "restaurant_id"
    type = "S"
  }

  attribute {
    name = "review_id"
    type = "S"
  }

  # GSI를 위한 user_id 속성 추가
  attribute {
    name = "user_id"
    type = "S"
  }

  # 사용자별 리뷰 조회를 위한 UserIdIndex
  global_secondary_index {
    name     = "UserIdIndex"
    hash_key = "user_id"
    projection_type = "ALL"  # 모든 속성을 GSI에 포함
  }

  # --- 태그 ---
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-${var.table_name}"
    }
  )
}