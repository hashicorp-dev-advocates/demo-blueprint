variable "cn_network" {
  default = "dc1"
}

variable "cn_nomad_cluster_name" {
  default = "nomad_cluster.local"
}

variable "cn_nomad_client_nodes" {
  default = 3
}


variable "cn_nomad_client_config" {
  default = "${data("nomad_config")}/client.hcl"
}

# Create a nomad host volume that waypoint can write persistent data to
variable "cn_nomad_client_host_volume" {
  default = {
    name        = "waypoint"
    source      = data("waypoint")
    destination = "/data"
    type        = "bind"
  }
}

variable "cn_nomad_load_image" {
  default = "shipyard.run/localcache/waypoint-odr:0.0.7"
}

# Override the Docker config to add the custom registry
variable "cn_nomad_docker_insecure_registries" {
  default = ["10.5.0.100"]
}


variable "minecraft_mods_path" {
  default = "${file_dir()}/minecraft/mods"
}

variable "minecraft_world_path" {
  default = "${file_dir()}/minecraft/world"
}

variable "minecraft_config_path" {
  default = "${file_dir()}/minecraft/config"
}

variable "minecraft_server_icon_path" {
  default = "${file_dir()}/minecraft"
}

variable "minecraft_enable_backups" {
  default = false
}

variable "minecraft_enable_geyser" {
  default = true
}

variable "minecraft_restic_repository" {
  default = "${file_dir()}/backups/backup"
}

variable "minecraft_restic_password" {
  default = "password"
}

variable "minecraft_restic_backup_path" {
  default = "${file_dir()}/backups/minecraft"
}

variable "minecraft_restic_backup_interval" {
  default = 300
}

# World archive to restore to server, only restores when ./minecraft folder is empty
variable "minecraft_world_backup" {
  default = "https://github.com/hashicorp-dev-advocates/demo-blueprint/releases/download/v0.1.0/hashiconf.tar.gz"
}

# Set these variables to false to disable a particular module
variable "install_monitoring" {
  default = true
}

variable "install_waypoint" {
  default = true
}

variable "install_vault" {
  default = true
}

variable "install_controller" {
  default = "docker"
  #default = "local"
}

variable "install_example_app" {
  default = true
}

## Run the Minecraft server
variable "install_minecraft" {
  default = true
}

# Run the browserless app to enable screenshots from URLs
# used by Projector to display browsers in Minecraft
variable "install_browserless" {
  default = true
}