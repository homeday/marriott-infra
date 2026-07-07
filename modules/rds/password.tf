resource "aws_secretsmanager_secret" "db" {
  count = local.create_password_secret ? 1 : 0
  name  = "rds-aurora/${var.cluster_name}-master"
}

resource "aws_secretsmanager_secret_version" "db" {
  count     = local.create_password_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.db[0].id

  secret_string = jsonencode({
    username = "postgres"
    password = random_password.master[0].result
  })
}

resource "random_password" "master" {
  count   = local.create_password_secret ? 1 : 0
  length  = 20
  special = false
  keepers = {
    version = 2
  }
}
