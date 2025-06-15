resource "aws_dynamodb_table" "events_table" {
  name           = var.events_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "event_id"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  attribute {
    name = "event_id"
    type = "S"
  }
  server_side_encryption {
    enabled = true
  }
}

resource "aws_dynamodb_table" "subscriptions_table" {
  name           = var.subscriptions_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "subscriber_id"
  attribute {
    name = "subscriber_id"
    type = "S"
  }
  server_side_encryption {
    enabled = true
  }
}