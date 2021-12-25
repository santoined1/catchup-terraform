resource "aws_instance" "pub" {
  ami = "0ed9277fb7eb570c9"
  instance_type =" t2.micro"
  
}

resource "aws_s3_bucket" "data_team_bucket" {
  bucket = var.bucket_name
  acl    = "private"

server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

 tags = {
    Name        = "My-bucket"
    Environment = "Dev"
    terraform = true
  }
 

}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  enable_key_rotation = true
  policy = data.aws_iam_policy_document.key_policy.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "key_policy" {
  statement {
    sid = "grant root full access to this key"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = ["kms:*"]
    resources = ["*"]
}
     
}