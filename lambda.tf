provider "aws" {
  alias = "us-east"
  region = "us-east-1"
}

data "template_file" "lambda_code" {
  template = "${file("${path.module}/auth.js")}"

  vars {
    username = "${var.username}"
    password = "${var.password}"
  }
}

data "archive_file" "auth" {
  type = "zip"
  output_path = "${path.root}/.zip/auth.zip"
  source {
    filename = "index.js"
    content = "${data.template_file.lambda_code.rendered}"
  }
}

resource "aws_lambda_function" "auth" {
  provider = "aws.us-east"
  function_name = "lambda-auth-${var.project}"
  filename = "${data.archive_file.auth.output_path}"
  source_code_hash = "${data.archive_file.auth.output_base64sha256}"
  role = "${aws_iam_role.main.arn}"
  runtime = "nodejs10.x"
  handler = "index.handler"
  memory_size = 128
  timeout = 3
  publish = true

  tags = "${merge("${var.tags}",map("Name", "${var.project}-${var.environment}-${var.domain}", "Environment", "${var.environment}", "Project", "${var.project}"))}"
}
