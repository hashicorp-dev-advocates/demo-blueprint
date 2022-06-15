
container "restic" {
  disabled = !var.minecraft_enable_backups

  network {
    name = "network.${var.cn_network}"
  }

  image {
    name = "hashicraft/restic:${var.minecraft_restic_version}"
  }

  volume {
    source      = var.minecraft_restic_backup_path
    destination = "/data"
  }

  env {
    key   = "BACKUP_PATH"
    value = "/data"
  }

  env {
    key   = "BACKUP_INTERVAL"
    value = var.minecraft_restic_backup_interval
  }

  env {
    key   = "RESTIC_REPOSITORY"
    value = var.minecraft_restic_repository
  }

  env {
    key   = "RESTIC_PASSWORD"
    value = var.minecraft_restic_password
  }

  env {
    key   = "AWS_ACCESS_KEY_ID"
    value = var.minecraft_restic_key
  }

  env {
    key   = "AWS_SECRET_ACCESS_KEY"
    value = var.minecraft_restic_secret
  }
}