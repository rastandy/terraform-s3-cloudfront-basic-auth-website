provider "aws" {
  alias = "us-east"
  region = "us-east-1"
}

data "archive_file" "auth" {
  type = "zip"
  output_path = "${path.module}/.zip/auth.zip"
  source {
    filename = "index.js"
    content = "${file("${path.module}/auth.js")}"
  }
}

resource "aws_lambda_function" "auth" {
  provider = "aws.us-east"
  function_name = "auth"
  filename = "${data.archive_file.auth.output_path}"
  source_code_hash = "${data.archive_file.auth.output_base64sha256}"
  role = "${aws_iam_role.main.arn}"
  runtime = "nodejs8.10"
  handler = "index.handler"
  memory_size = 128
  timeout = 3
  publish = true
}
