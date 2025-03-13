# ✅ cloud provider
provider "aws" {
  region = "us-east-1"
}



# ✅ Create IAM User
resource "aws_iam_user" "user" {
  name = "servicenow-user"
  tags = {
    request_id = "SNOW12345"
    requester  = "sunilkm88@gmail.com"