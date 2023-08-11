resource "aws_iam_user" "user" {
  name = "${var.prefix}-${var.app_environment}-${var.title}"

  force_destroy = true
}

resource "aws_iam_policy" "user-policy" {
  name        = "${var.prefix}-${var.app_environment}-${var.title}-policy"
  description = "${var.description}"

  policy = var.policy
}

resource "aws_iam_user_policy_attachment" "user-policy-attach" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.user-policy.arn
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}