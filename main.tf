# ✅ cloud provider
provider "aws" {
  region = "us-east-1"
}

# ✅ Verify Email in AWS SES
resource "aws_ses_email_identity" "email" {
  email = "sunilkm88@gmail.com"
}


# ✅ Create IAM User
resource "aws_iam_user" "user" {
  name = "servicenow-user"
  tags = {
    request_id = "SNOW12345"
    requester  = "sunilkm88@gmail.com"