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

  # --- 태그 ---
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-${var.table_name}"
    }
  )
}