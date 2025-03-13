
# ✅ Create IAM User
resource "aws_iam_user" "user" {
  name = "var.user_name"
  tags = {
    request_id = "var.request_id"
    requester  = "var.requestermail_id"
  }
}

# ✅ Attach Correct S3 Read-Only Policy
resource "aws_iam_user_policy_attachment" "s3_read_access" {
  user       = aws_iam_user.user.name
  policy_arn = "var.policy_arn"

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
  "Requester Email": "var.requestermail_id",
  "Request ID": "var.request_id",
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
  "Source": "var.source_mail",
  "Destination": {
    "ToAddresses": "var.requestermail_id"
  },
  "Message": {
    "Subject": {
      "Data": "IAM Credentials for Request "${request_id}""
    },
    "Body": {
      "Text": {
        "Data": "Requester: "${Requester Email}"\nRequest ID: "${request_id}"\nIAM User ARN: ${aws_iam_user.user.arn}\nAccess Key: ${aws_iam_access_key.user_key.id}\nSecret Key: ${aws_iam_access_key.user_key.secret}"
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
  ]
}
