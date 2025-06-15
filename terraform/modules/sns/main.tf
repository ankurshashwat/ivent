resource "aws_sns_topic" "event_notifications" {
  name = var.sns_topic_name
}
