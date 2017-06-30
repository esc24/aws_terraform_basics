provider "aws" {
  region = "eu-west-2"
}


resource "aws_sns_topic" "topic" {
  name = "s3-event-notification-topic"

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {"AWS":"*"},
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:s3-event-notification-topic",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${aws_s3_bucket.bucket.arn}"}
        }
    }]
}
POLICY
}

resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "${var.bucket_prefix}"
  force_destroy = true
  request_payer = "Requester"
  
  tags {
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket        = "${aws_s3_bucket.bucket.id}"
  
  topic {
    topic_arn   = "${aws_sns_topic.topic.arn}"
    events      = ["s3:ObjectCreated:*"]
  }
}
