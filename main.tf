provider "aws" {
  alias  = "${var.region}"
  region = "${var.region}"
}

resource "aws_s3_bucket" "website_bucket" {
  provider = "aws.${var.region}"
  bucket   = "${var.bucket_name}"
  policy   = "${data.template_file.bucket_policy.rendered}"

  website {
    index_document = "index.html"
    error_document = "404.html"
    routing_rules  = "${var.routing_rules}"
  }

  tags = "${merge("${var.tags}",map("Name", "${var.project}-${var.environment}-${var.domain}", "Environment", "${var.environment}", "Project", "${var.project}"))}"
}

#############################################################################
## Create a Cloudfront distribution for the s3 bucket
#############################################################################
resource "aws_cloudfront_distribution" "website_cdn" {
  enabled      = true
  price_class  = "${var.price_class}"
  http_version = "http2"

  "origin" {
    origin_id   = "origin-bucket-${aws_s3_bucket.website_bucket.id}"
    domain_name = "${aws_s3_bucket.website_bucket.website_endpoint}"

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1"]
    }

    custom_header {
      name  = "User-Agent"
      value = "${var.duplicate-content-penalty-secret}"
    }
  }

  default_root_object = ${var.default_root_object}

  custom_error_response = ["${var.custom_error_response}"]

  "default_cache_behavior" {
    allowed_methods = ["GET", "HEAD", "DELETE", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = "${aws_lambda_function.auth.qualified_arn}"
    }

    "forwarded_values" {
      query_string = "${var.forward-query-string}"

      cookies {
        forward = "none"
      }
    }

    trusted_signers = ["${var.trusted_signers}"]

    min_ttl          = "0"
    default_ttl      = "300"                                              //3600
    max_ttl          = "1200"                                             //86400
    target_origin_id = "origin-bucket-${aws_s3_bucket.website_bucket.id}"

    // This redirects any HTTP request to HTTPS. Security first!
    viewer_protocol_policy = "${var.viewer_protocol_policy}"
    compress               = true
  }

  "restrictions" {
    "geo_restriction" {
      restriction_type = "none"
    }
  }

  "viewer_certificate" {
    acm_certificate_arn      = "${var.acm-certificate-arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  aliases = ["${var.domain}"]

  tags = "${merge("${var.tags}",map("Name", "${var.project}-${var.environment}-${var.domain}", "Environment", "${var.environment}", "Project", "${var.project}"))}"
}
