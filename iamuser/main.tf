# ✅ cloud provider
provider "aws" {
  region = "var.region"
}

# ✅ create iam user
module "iam" {
  source            = "../modules/iam"
  region            = var.region
  user_name         = var.user_name
  request_id        = var.request_id
  requestermail_id  = var.requestermail_id
  policy_arn        = var.policy_arn
  source_mail       = var.source_mail
}