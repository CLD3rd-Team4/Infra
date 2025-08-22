resource "aws_dynamodb_table" "this" {
  # --- 네이밍 ---
  name           = "${var.name_prefix}${var.table_name}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "restaurant_id"
  range_key      = "created_at_user_id"  

  attribute {
    name = "restaurant_id"
    type = "S"
  }

  attribute {
    name = "created_at_user_id"
    type = "S"
  }

  # GSI를 위한 user_id 속성 추가
  attribute {
    name = "user_id"
    type = "S"
  }

  # GSI를 위한 created_at 속성 추가
  attribute {
    name = "created_at"
    type = "S"
  }

  # 리뷰 상태 속성 (DRAFT, PUBLISHED, DELETED)
  attribute {
    name = "review_status"
    type = "S"
  }

  # 평점 기반 GSI를 위한 속성들
  attribute {
    name = "rating_category"
    type = "S"
  }

  # 추천용 GSI를 위한 속성
  attribute {
    name = "verified_rating_status"
    type = "S"
  }

  # 지역 기반 GSI를 위한 속성
  attribute {
    name = "address_region"
    type = "S"
  }

  # 사용자별 리뷰 조회를 위한 UserIdIndex (시간순 정렬)
  global_secondary_index {
    name     = "UserIdIndex"
    hash_key = "user_id"
    range_key = "created_at"
    projection_type = "ALL"  
  }

  # 미작성 리뷰 조회를 위한 StatusIndex (상태별 조회)
  global_secondary_index {
    name     = "StatusIndex"
    hash_key = "review_status"
    range_key = "created_at"
    projection_type = "ALL"
  }

  # 평점 기반 GSI (RatingIndex)
  global_secondary_index {
    name     = "RatingIndex"
    hash_key = "rating_category"
    range_key = "created_at"
    projection_type = "ALL"
  }

  # 추천용 GSI (RecommendationIndex)
  global_secondary_index {
    name     = "RecommendationIndex"
    hash_key = "verified_rating_status"
    range_key = "created_at"
    projection_type = "ALL"
  }

  # 지역 기반 GSI (AddressIndex)
  global_secondary_index {
    name     = "AddressIndex"
    hash_key = "address_region"
    range_key = "created_at"
    projection_type = "ALL"
  }

  # --- 태그 ---
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-${var.table_name}"
    }
  )

  point_in_time_recovery {
    enabled = terraform.workspace == "prod" ? true : false
  }
}

# Pending Review 테이블
resource "aws_dynamodb_table" "pending_review" {
  name           = "${var.name_prefix}review-pending"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "user_id"
  range_key      = "restaurant_id_scheduled_time"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "restaurant_id_scheduled_time"
    type = "S"
  }

  attribute {
    name = "restaurant_id"
    type = "S"
  }

  attribute {
    name = "scheduled_time"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  # 레스토랑별 pending review 조회를 위한 GSI
  global_secondary_index {
    name     = "RestaurantIndex"
    hash_key = "restaurant_id"
    range_key = "scheduled_time"
    projection_type = "ALL"
  }

  # 생성 시간별 조회를 위한 GSI  
  global_secondary_index {
    name     = "CreatedAtIndex"
    hash_key = "user_id"
    range_key = "created_at"
    projection_type = "ALL"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-review-pending"
    }
  )

  point_in_time_recovery {
    enabled = terraform.workspace == "prod" ? true : false
  }
}