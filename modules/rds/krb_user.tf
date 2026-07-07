provider "postgresql" {
  host            = module.aurora.cluster_endpoint
  port            = 5432
  username        = jsondecode(aws_secretsmanager_secret_version.db[0].secret_string)["username"]
  password        = jsondecode(aws_secretsmanager_secret_version.db[0].secret_string)["password"]
  sslmode         = "require"
  connect_timeout = 15
}

resource "postgresql_role" "ad_user" {
  count = local.create_ad_user ? 1 : 0
  name  = var.ad_user_name
  login = true

  depends_on = [module.aurora]
}

resource "postgresql_grant_role" "grant_rds_ad" {
  count      = local.create_ad_user ? 1 : 0
  role       = postgresql_role.ad_user[0].name
  grant_role = "rds_ad"
}