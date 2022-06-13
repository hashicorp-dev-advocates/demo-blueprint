// set the variable for the network
variable "cn_network" {
  default = "dc1"
}

variable "cn_nomad_cluster_name" {
  default = "nomad_cluster.local"
}

variable "cn_nomad_client_nodes" {
  default = 0
}

network "dc1" {
  subnet = "10.5.0.0/16"
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
  default = "${home()}/minecraft/mods"
}

variable "minecraft_world_path" {
  default = "${home()}/minecraft/world"
}

variable "minecraft_config_path" {
  default = "${home()}/minecraft/config"
}

variable "minecraft_server_icon_path" {
  default = "${home()}/minecraft"
}

variable "restic_repository" {
  default = "${home()}/backup"
}

variable "restic_password" {
  default = "password"
}

variable "restic_backup_path" {
  default = "${home()}/minecraft"
}

variable "restic_backup_interval" {
  default = 300
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

variable "install_minecraft" {
  default = true
}

variable "install_restic" {
  default = true
}

module "consul_nomad" {
  depends_on = ["container.waypoint-odr"]
  source     = "github.com/shipyard-run/blueprints?ref=d9446bfc97759e66b82b1fed60fd70c94ab98238/modules//consul-nomad"
  #source = "/home/nicj/go/src/github.com/shipyard-run/blueprints/modules/consul-nomad"
}

#copy "test" {
#  source      = "./certs"
#  destination = var.cn_nomad_client_host_volume.source
#}

module "monitoring" {
  depends_on = ["module.consul_nomad"]
  disabled   = ! var.install_monitoring

  source = "./modules/monitoring"
}

module "waypoint" {
  disabled = ! var.install_waypoint

  source = "./modules/waypoint"
}

module "example_app" {
  disabled = ! var.install_example_app

  source = "./modules/example_app"
}

module "controller" {
  depends_on = ["module.consul_nomad"]
  disabled   = var.install_controller == ""

  source = "./modules/releaser"
}

module "vault" {
  disabled = ! var.install_vault

  source = "./modules/vault"
}

module "minecraft" {
  disabled = ! var.install_minecraft

  source = "./modules/minecraft"
}

module "restic" {
  disabled = ! var.install_restic

  source = "./modules/restic"
}

#module "boundary" {
#  disabled = var.install_controller == ""
#
#  source = "./modules/releaser"
#}