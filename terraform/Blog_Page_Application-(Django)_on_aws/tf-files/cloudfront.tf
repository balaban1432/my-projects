resource "aws_cloudfront_distribution" "elb_distribution" {
  origin {
    domain_name = aws_lb.capstone-lb.dns_name
    origin_id   = "ALBOriginId"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "match-viewer"
      origin_ssl_protocols     = ["TLSv1"]
    }
  }

  enabled = true

  aliases = [var.subdomain]

  default_cache_behavior {
    target_origin_id = "ALBOriginId"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }

      headers = ["Host", "Accept", "Accept-Charset", "Accept-Datetime", "Accept-Encoding", "Accept-Language", "Authorization", "Cloudfront-Forwarded-Proto", "Origin", "Referrer"]
    }
  }

  price_class = "PriceClass_All"

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  comment = "Cloudfront Distribution pointing to ALBDNS"
  restrictions {
    geo_restriction {
      restriction_type = "none" 
    }
  }
}