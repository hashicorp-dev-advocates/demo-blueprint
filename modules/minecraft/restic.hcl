variable "minecraft_restic_version" {
  default = "v0.0.1"
}

variable "minecraft_restic_backup_path" {
  default = "${data("minecraft")}"
}

variable "minecraft_restic_backup_interval" {
  default = 300
}

variable "minecraft_restic_repository" {
  default = "${data("restic")}"
}

variable "minecraft_restic_password" {
  default = "password"
}

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
}