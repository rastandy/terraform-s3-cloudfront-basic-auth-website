variable "region" {
  default = "eu-central-1"
}

variable "project" {
  default = "noproject"
}

variable "environment" {
  default = "default"
}

variable "domain" {}

variable "bucket_name" {
  description = "The name of the S3 bucket to create."
}

variable "username" {}
variable "password" {}

variable "duplicate-content-penalty-secret" {}
variable "deployer" {}
variable "acm-certificate-arn" {}

variable "routing_rules" {
  default = ""
}

variable "default_root_object" {
  default = "index.html"
}

variable "not-found-response-path" {
  default = "/404.html"
}

variable "tags" {
  type        = "map"
  description = "Optional Tags"
  default     = {}
}

variable "trusted_signers" {
  type = "list"
  default = []
}

variable "forward-query-string" {
  description = "Forward the query string to the origin"
  default     = false
}

variable "price_class" {
  description = "CloudFront price class"
  default     = "PriceClass_200"
}

variable "viewer_protocol_policy" {
  description = "CloudFront viewer protocol policy"
  default     = "redirect-to-https"
}

variable "custom_error_response" {
  # http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/custom-error-pages.html#custom-error-pages-procedure
  # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#custom-error-response-arguments
  description = "(Optional) - List of one or more custom error response element maps"

  type    = "list"
  default = [{
    error_code            = "404"
    error_caching_min_ttl = "360"
    response_code         = "200"
    response_page_path    = "/404.html"
  }]
}
