# ✅ cloud provider
provider "aws" {
  region = "us-east-1"
}

# ✅ Verify Email in AWS SES
resource "aws_ses_email_identity" "email" {
  email = "harishh1265@gmail.com"
}


# ✅ Create IAM User
resource "aws_iam_user" "user" {
  name = "servicenow-user"
  tags = {
    request_id = "SNOW12345"
    requester  = "harishh1265@gmail.com"
  }
}

# ✅ Attach Correct S3 Read-Only Policy
resource "aws_iam_user_policy_attachment" "s3_read_access" {
  user       = aws_iam_user.user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"

  depends_on = [aws_iam_user.user]
}

# ✅ Generate IAM User Access & Secret Keys
resource "aws_iam_access_key" "user_key" {
  user = aws_iam_user.user.name
}

# ✅ Store IAM Credentials in a Local File
resource "local_file" "creds" {
  filename = "creds.json"
  content  = <<EOT
{
  "Requester Email": "harishh1265@gmail.com",
  "Request ID": "SNOW12345",
  "IAM User ARN": "${aws_iam_user.user.arn}",
  "Access Key": "${aws_iam_access_key.user_key.id}",
  "Secret Key": "${aws_iam_access_key.user_key.secret}"
}
EOT
}

# ✅ Verify Email in AWS SES
# ✅ Create an email JSON file using Terraform
resource "local_file" "email_json" {
  filename = "email.json"
  content  = <<EOT
{
  "Source": "harishh1265@gmail.com",
  "Destination": {
    "ToAddresses": ["harishh1265@gmail.com"]
  },
  "Message": {
    "Subject": {
      "Data": "IAM Credentials for Request SNOW12345"
    },
    "Body": {
      "Text": {
        "Data": "Requester: harishh1265@gmail.com\nRequest ID: SNOW12345\nIAM User ARN: ${aws_iam_user.user.arn}\nAccess Key: ${aws_iam_access_key.user_key.id}\nSecret Key: ${aws_iam_access_key.user_key.secret}"
      }
    }
  }
}
EOT
}

# ✅ Execute the AWS SES send-email command
resource "null_resource" "send_email" {
  provisioner "local-exec" {
  command = "aws ses send-email --cli-input-json file://email.json --region us-east-1"
    }
  depends_on = [
    local_file.email_json,    
    aws_iam_access_key.user_key,
    aws_ses_email_identity.email
  ]
}
