data "aws_iam_policy_document" "auth_role"{
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    
    principals {
      type = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    
    condition {
      test      = "StringEquals"
      variable  = "cognito-identity.amazonaws.com:aud"
      values = [
        "${aws_cognito_identity_pool.main.id}"
      ]
    }
    condition {
      test      = "ForAnyValue:StringLike"
      variable  = "cognito-identity.amazonaws.com:amr"
      values = [
        "authenticated"
      ]
    }
  }
}

data "aws_iam_policy_document" "unauth_role"{
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    
    principals {
      type = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    
    condition {
      test      = "StringEquals"
      variable  = "cognito-identity.amazonaws.com:aud"
      values = [
        "${aws_cognito_identity_pool.main.id}"
      ]
    }
    condition {
      test      = "ForAnyValue:StringLike"
      variable  = "cognito-identity.amazonaws.com:amr"
      values = [
        "unauthenticated"
      ]
    }
  }
}

data "aws_iam_policy_document" "auth_policy"{
  statement {
    actions = [
      "mobileanalytics:PutEvents",
      "cognito-sync:*",
      "cognito-identity:*"
    ]
    resources = ["*"]
  }  
  statement {
    actions = ["execute-api:Invoke"]
    resources = ["arn:aws:execute-api:${var.region}:*:0y4cx4tk2e/*/*/*"]
  }
}

data "aws_iam_policy_document" "unauth_policy"{
  statement {
    actions = [
      "mobileanalytics:PutEvents",
      "cognito-sync:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "auth_role"{
  name               = "cognito-${local.identifier}-auth-role"
  assume_role_policy = data.aws_iam_policy_document.auth_role.json
  inline_policy {
    name   = "cognito-${local.identifier}-auth-inline-policy"
    policy = data.aws_iam_policy_document.auth_policy.json
  }
}

resource "aws_iam_role" "unauth_role"{
  name               = "cognito-${local.identifier}-unauth-role"
  assume_role_policy = data.aws_iam_policy_document.unauth_role.json
  inline_policy {
    name   = "cognito-${local.identifier}-unauth-inline-policy"
    policy = data.aws_iam_policy_document.unauth_policy.json
  }
}