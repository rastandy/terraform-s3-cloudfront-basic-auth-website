data "aws_iam_policy_document" "lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "main" {
  name_prefix = "${var.bucket_name}"
  assume_role_policy = "${data.aws_iam_policy_document.lambda.json}"
}

resource "aws_iam_role_policy_attachment" "basic" {
  role = "${aws_iam_role.main.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


###############################################################################
## Configure the credentials and access to the bucket for a deployment user
###############################################################################
data "template_file" "deployer_role_policy_file" {
  template = "${file("${path.module}/deployer_role_policy.json")}"

  vars {
    bucket = "${var.bucket_name}"
  }
}

resource "aws_iam_policy" "site_deployer_policy" {
  provider    = "aws.${var.region}"
  name        = "${var.bucket_name}.deployer"
  path        = "/"
  description = "Policy allowing to publish a new version of the website to the S3 bucket"
  policy      = "${data.template_file.deployer_role_policy_file.rendered}"
}

resource "aws_iam_policy_attachment" "site-deployer-attach-user-policy" {
  provider   = "aws.${var.region}"
  name       = "${var.bucket_name}-deployer-policy-attachment"
  users      = ["${var.deployer}"]
  policy_arn = "${aws_iam_policy.site_deployer_policy.arn}"
}
