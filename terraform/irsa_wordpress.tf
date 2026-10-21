data "aws_iam_policy_document" "wordpress_media_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:default:wordpress"]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "wordpress_media" {
  name               = "aws-eks-wordpress-media-role"
  assume_role_policy = data.aws_iam_policy_document.wordpress_media_assume.json
}

data "aws_iam_policy_document" "wordpress_media_s3" {
  statement {
    sid       = "ObjectAccess"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.media.arn}/*"]
  }

  statement {
    sid    = "BucketAccess"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketOwnershipControls",
    ]
    resources = [aws_s3_bucket.media.arn]
  }
}

resource "aws_iam_role_policy" "wordpress_media_s3" {
  name   = "wordpress-media-s3-access"
  role   = aws_iam_role.wordpress_media.id
  policy = data.aws_iam_policy_document.wordpress_media_s3.json
}
