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
    key   = "MODS_BACKUP"
    value = var.minecraft_mods_backup
  }

  env {
    key   = "PROJECTOR_render"
    value = "${var.render_uri}/image"
  }

  env {
    key   = "PROJECTOR_nomad"
    value = "${var.render_uri}/image?url=http%3A//server.local.nomad-cluster.shipyard.run%3A4646"
  }

  env {
    key   = "PROJECTOR_consul"
    value = "${var.render_uri}/image?url=http%3A//consul.container.shipyard.run%3A8500"
  }

  env {
    key   = "PROJECTOR_grafana"
    value = "${var.render_uri}/image?url=http%3A//1.client.local.nomad-cluster.ingress.shipyard.run%3A18081"
  }
}

sidecar "geyser" {
  disabled = !var.minecraft_enable_backups
  target   = "container.minecraft"

  image {
    name = "hashicraft/geyser:${var.minecraft_geyser_version}"
  }

  command = ["/start.sh", "--remote.address", "minecraft.container.shipyard.run"]
}
