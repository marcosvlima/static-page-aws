###################################
# IAM Policy Document
###################################
data "aws_iam_policy_document" "read_static_page_bucket" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_page.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.static_page.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.static_page.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.static_page.iam_arn]
    }
  }
}

###################################
# S3
###################################
resource "aws_s3_bucket" "static_page" {
  bucket = "static_page_marcosvlimacloud01"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

###################################
# S3 Bucket Policy
###################################
resource "aws_s3_bucket_policy" "read_static_page" {
  bucket = aws_s3_bucket.static_page.id
  policy = data.aws_iam_policy_document.read_static_page_bucket.json
}

###################################
# S3 Bucket Public Access Block
###################################
resource "aws_s3_bucket_public_access_block" "static_page" {
  bucket = aws_s3_bucket.static_page.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = false
}

##

###################################
# CloudFront
###################################
resource "aws_cloudfront_distribution" "static_page" {
  enabled             = true
  default_root_object = "index.html"
  aliases             = [aws_s3_bucket.static_page.bucket]

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.static_page.bucket
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    min_ttl     = 0
    default_ttl = 5 * 60
    max_ttl     = 60 * 60

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }

  origin {
    # domain_name = aws_s3_bucket.static_page.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.static_page.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static_page.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

#   viewer_certificate {
#     # Huh? Another spoiler?
#     acm_certificate_arn      = aws_acm_certificate_validation.cf_static_page.certificate_arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2018"
#   }
}