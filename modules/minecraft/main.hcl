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

variable "minecraft_network" {
  default = var.cn_network
}

variable "geyser_version" {
  default = "v0.0.2"
}

container "minecraft" {
  network {
    name = "network.${var.minecraft_network}"
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

  env {
    key   = "JAVA_MEMORY"
    value = "8G"
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
}

container "geyser" {
  network {
    name = "network.${var.minecraft_network}"
  }

  image {
    name = "hashicraft/geyser:${var.geyser_version}"
  }

  command = ["/start.sh", "--remote.address", "minecraft.container.shipyard.run"]

  port {
    local  = 19132
    remote = 19132
    host   = 19132
  }
}
