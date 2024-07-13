
#create django bucket with ACL enabled
resource "aws_s3_bucket" "capstonedjango" {
  bucket = "${var.project_name}-osvaldo-django"
  force_destroy = true
}


resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.capstonedjango.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "pulicblock" {
  bucket = aws_s3_bucket.capstonedjango.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.ownership,
    aws_s3_bucket_public_access_block.pulicblock,
  ]

  bucket = aws_s3_bucket.capstonedjango.id
  acl    = "public-read"
}



#create Route53 Failover bucket

resource "aws_s3_bucket" "Route53" {
  bucket = var.subdomain
}

resource "aws_s3_bucket_policy" "allow_access_from_public" {
  bucket = aws_s3_bucket.Route53.id
  policy = data.aws_iam_policy_document.allow_access_to_r53bucket.json
}

resource "aws_s3_bucket_public_access_block" "r53" {
    bucket = aws_s3_bucket.Route53.id
    block_public_acls       = false
    block_public_policy     = false
}

data "aws_iam_policy_document" "allow_access_to_r53bucket" {
  statement {

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.Route53.arn,
      "${aws_s3_bucket.Route53.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_website_configuration" "r53webconf" {
  bucket = aws_s3_bucket.Route53.id

  index_document {
    suffix = "index.html"
  }
}