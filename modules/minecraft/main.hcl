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

variable "minecraft_enable_geyser" {
  default = true
}

variable "minecraft_restic_repository" {
  default = ""
}

variable "minecraft_restic_key" {
  default = ""
}

variable "minecraft_restic_secret" {
  default = ""
}

variable "minecraft_restic_password" {
  default = ""
}

variable "minecraft_restic_version" {
  default = "v0.0.1"
}

variable "minecraft_restic_backup_interval" {
  default = 1200
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
    local    = 19132
    remote   = 19132
    host     = 19132
    protocol = "udp"
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

  env {
    key   = "WHISKERS_ADDR"
    value = "http://1.client.local.nomad-cluster.shipyard.run:18084"
  }

  env {
    key   = "SCOREBOARD_ADDR"
    value = "http://scoreboard.container.shipyard.run:4000"
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
    value = "${var.render_uri}/image?url=http%3A//1.client.local.nomad-cluster.shipyard.run%3A18081"
  }
}

template "geyser_config" {

  source = <<-EOF
    bedrock:
      address: 0.0.0.0
      port: 19132
      clone-remote-port: false
      motd1: "Geyser"
      motd2: "Another Geyser server."
      server-name: "Geyser"
      compression-level: 6
      enable-proxy-protocol: false
    remote:
      address: auto
      port: 25565
      auth-type: floodgate
      allow-password-authentication: true
      use-proxy-protocol: false
      forward-hostname: false

    floodgate-key-file: key.pem

    saved-user-logins:
      - ThisExampleUsernameShouldBeLongEnoughToNeverBeAnXboxUsername
      - ThisOtherExampleUsernameShouldAlsoBeLongEnough

    pending-authentication-timeout: 120
    command-suggestions: true
    passthrough-motd: false
    passthrough-protocol-name: false
    passthrough-player-counts: false
    legacy-ping-passthrough: false
    ping-passthrough-interval: 3
    forward-player-ping: false
    max-players: 100
    debug-mode: false
    allow-third-party-capes: true
    allow-third-party-ears: false
    show-cooldown: title
    show-coordinates: true
    disable-bedrock-scaffolding: false
    emote-offhand-workaround: "disabled"
    cache-images: 0
    allow-custom-skulls: true
    max-visible-custom-skulls: 128
    custom-skull-render-distance: 32
    add-non-bedrock-items: true
    above-bedrock-nether-building: false
    force-resource-packs: true
    xbox-achievements-enabled: false

    metrics:
      enabled: true
      uuid: fffb5140-77bc-45f9-b251-6f9fd4712ad9

    scoreboard-packet-threshold: 20
    enable-proxy-connections: false
    mtu: 1400
    use-direct-connection: true
    config-version: 4 
  EOF

  destination = "${data("minecraft")}/config.yaml"
}

sidecar "geyser" {
  disabled = !var.minecraft_enable_geyser
  target   = "container.minecraft"

  image {
    name = "hashicraft/geyser:${var.minecraft_geyser_version}"
  }

  #volume {
  #  $ { data("minecraft") } / config.yaml
  #}

  command = ["/start.sh", "--remote.address", "minecraft.container.shipyard.run"]
}
