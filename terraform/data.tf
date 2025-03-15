# EC2 IMAGE / S3 BUCKET POLICY

data "aws_ami" "soo_ec2_image" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
data "aws_elb_service_account" "main" {}
# Load Balancer

data "aws_iam_policy_document" "soo_s3_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn] # whom to use!
      # TRY TO IAM USER -> IF NOT RESOURCE ARN
      # LoadBalancer needs to access logs, too!
      # If it's complicated, identifiers: [*]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutBucketPolicy"
    ]

    resources = [
      aws_s3_bucket.soo_s3_bucket.arn,
      "${aws_s3_bucket.soo_s3_bucket.arn}/*",
    ]
  }
}

data "aws_route53_zone" "soo_dns" {
  name         = var.soo_dns # FQDN
  private_zone = false
}