variable "minecraft_version" {
  default = "v1.18.2-fabric"
}

variable "minecraft_mods_path" {
  default = "${data("minecraft")}/mods"
}

variable "minecraft_plugins_path" {
  default = "${data("minecraft")}/plugins"
}

variable "minecraft_world_path" {
  default = "${data("minecraft")}/world"
}

variable "minecraft_worlds_path" {
  default = "${data("minecraft")}/worlds"
}

variable "minecraft_config_path" {
  default = "${data("minecraft")}/config"
}

variable "minecraft_server_icon_path" {
  default = "${data("minecraft")}/server-icon.png"
}

variable "minecraft_geyser_version" {
  default = "v0.0.2"
}

variable "minecraft_memory" {
  default = "2G"
}

# Location of a tar archive that contains the world to restore to the server
variable "minecraft_world_backup" {
  default = ""
}

container "minecraft" {
  network {
    name = "network.${var.cn_network}"
  }

  image {
    name = "hashicraft/minecraft:${var.minecraft_version}"
  }

  volume {
    source      = var.minecraft_mods_path
    destination = "/minecraft/mods"
  }

  volume {
    source      = var.minecraft_plugins_path
    destination = "/minecraft/plugins"
  }

  volume {
    source      = var.minecraft_server_icon_path
    destination = "/minecraft/server-icon.png"
  }

  volume {
    source      = var.minecraft_world_path
    destination = "/minecraft/world"
  }

  volume {
    source      = var.minecraft_worlds_path
    destination = "/minecraft/worlds"
  }

  volume {
    source      = var.minecraft_config_path
    destination = "/minecraft/config"
  }

  port {
    local  = 25565
    remote = 25565
    host   = 25565
  }

  port {
    local  = 27015
    remote = 27015
    host   = 27015
  }

  port {
    local  = 19132
    remote = 19132
    host   = 19132
  }

  env {
    key   = "JAVA_MEMORY"
    value = var.minecraft_memory
  }

  env {
    key   = "MINECRAFT_MOTD"
    value = "HashiCraft"
  }

  env {
    key   = "WHITELIST_ENABLED"
    value = "false"
  }

  env {
    key   = "RCON_PASSWORD"
    value = "password"
  }

  env {
    key   = "RCON_ENABLED"
    value = "true"
  }

  env {
    key   = "WORLD_BACKUP"
    value = var.minecraft_world_backup
  }

  env {
    key   = "NOMAD_ADDR"
    value = "http://server.local.nomad-cluster.shipyard.run:4646"
  }

  env {
    key   = "VAULT_ADDR"
    value = "http://vault.container.shipyard.run:8200"
  }

  env {
    key   = "VAULT_TOKEN"
    value = "root"
  }

  env {
    key   = "RELEASER_ADDR"
    value = "http://1.client.local.nomad-cluster.shipyard.run:18083"
  }
}

sidecar "geyser" {
  disabled = ! var.minecraft_enable_backups

  target = "container.minecraft"

  image {
    name = "hashicraft/geyser:${var.minecraft_geyser_version}"
  }

  command = ["/start.sh", "--remote.address", "minecraft.container.shipyard.run"]
}
