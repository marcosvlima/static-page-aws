provider "aws" {
  region = "us-east-1" # Substitua pela sua região AWS desejada
}

resource "aws_s3_bucket" "static_website" {
  bucket = "Cloudfront-marcosvlimacloud01" # Substitua pelo nome do seu bucket
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

resource "aws_cloudfront_distribution" "static_website_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_website.website_endpoint
    origin_id   = "s3-origin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.static_website_distribution.domain_name
