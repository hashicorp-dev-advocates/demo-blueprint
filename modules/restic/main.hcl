variable "restic_version" {
  default = "v0.0.1"
}

variable "restic_backup_path" {
  default = "${data("minecraft")}"
}

variable "restic_backup_interval" {
  default = 300
}

variable "restic_repository" {
  default = "${data("restic")}"
}

variable "restic_password" {
  default = "password"
}

variable "restic_network" {
  default = var.cn_network
}

container "restic" {
  network {
    name = "network.${var.restic_network}"
  }

  image {
    name = "hashicraft/restic:${var.restic_version}"
  }

  volume {
    source      = var.restic_backup_path
    destination = "/data"
  }

  env {
    key   = "BACKUP_PATH"
    value = "/data"
  }

  env {
    key   = "BACKUP_INTERVAL"
    value = var.restic_backup_interval
  }

  env {
    key   = "RESTIC_REPOSITORY"
    value = var.restic_repository
  }
}