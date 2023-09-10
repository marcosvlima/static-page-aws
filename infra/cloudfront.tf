module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"

  comment             = "Static Page"
  enabled             = true
  is_ipv6_enabled     = false
  wait_for_deployment = false

  create_origin_access_identity = true
    origin_access_identities = {
        s3_bucket_one = "bucket static page"
    }

  origin = {
    s3_one = {
      domain_name = "static-page.s3.amazonaws.com"
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id           = "something"
    viewer_protocol_policy     = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/static/*"
      target_origin_id       = "s3_one"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true
    }
  ]

}