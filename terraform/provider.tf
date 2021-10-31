provider "aws" {

  # Use (uncomment) only one option from below

  ## Option 1
  #  region     = "us-west-2"
  #  access_key = "my-access-key"
  #  secret_key = "my-secret-key"

  ## Option 2
  #  assume_role {
  #  role_arn     = "arn:aws:iam::<ACCOUTN_ID>:role/<ROLE_NAME>"
  #  session_name = "<SESSION_NAME>"
  #  }
  #  profile = "<AWS_PROFILE>"
  #  region  = var.region

  ## Option 3
  #  region                  = var.region
  #  shared_credentials_file = "/Users/tf_user/.aws/creds"
  #  profile                 = "<AWS_PROFILE>"

  ## Option 4
  #  Export AWS credentials in env
  #$ export AWS_ACCESS_KEY_ID="<ACCESS_KEY_ID>"
  #$ export AWS_SECRET_ACCESS_KEY="<SECRET_ACCESS_KEY>"
  #$ export AWS_DEFAULT_REGION="<AWS_REGION>"

}