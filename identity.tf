resource "aws_cognito_identity_pool" "main" {
  identity_pool_name    = "aluramed"

  cognito_identity_providers {
    client_id       = aws_cognito_user_pool_client.client.id 
    provider_name   = aws_cognito_user_pool.pool.endpoint
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id

  role_mapping {
    identity_provider         = "${aws_cognito_user_pool.pool.endpoint}:${aws_cognito_user_pool_client.client.id}"
    ambiguous_role_resolution = "AuthenticatedRole"
    type                      = "Rules"

    mapping_rule {
      claim      = "isAdmin"
      match_type = "Equals"
      role_arn   = aws_iam_role.auth_role.arn
      value      = "paid"
    }
  }

  role_mapping {
    identity_provider         = "${aws_cognito_user_pool.pool.endpoint}:${aws_cognito_user_pool_client.client.id}"
    ambiguous_role_resolution = "Deny"
    type                      = "Rules"

    mapping_rule {
      claim      = "isAdmin"
      match_type = "Equals"
      role_arn   = aws_iam_role.unauth_role.arn
      value      = "paid"
    }
  }

  roles = {
    "authenticated" = aws_iam_role.auth_role.arn,
    "unauthenticated" = aws_iam_role.unauth_role.arn
  }
}