network "dc1" {
  subnet = "10.5.0.0/16"
}

copy "waypoint_root_ca" {
  source      = "./certs"
  destination = var.cn_nomad_client_host_volume.source
}

module "consul_nomad" {
  disabled = !var.install_nomad

  //depends_on = ["container.waypoint-odr"]
  source = "github.com/shipyard-run/blueprints?ref=694e825167a05d6ae035a0b91f90ee7e8b2d2384/modules//consul-nomad"
}

module "monitoring" {
  disabled = !var.install_monitoring

  depends_on = ["module.consul_nomad"]
  source     = "./modules/monitoring"
}

module "waypoint" {
  disabled = !var.install_waypoint

  source = "./modules/waypoint"
}

module "example_app" {
  disabled = !var.install_example_app

  source = "./modules/example_app"
}

module "controller" {
  disabled = var.install_controller == ""

  source = "./modules/releaser"
}

module "vault" {
  disabled = !var.install_vault

  source = "./modules/vault"
}

module "browserless" {
  disabled = !var.install_browserless

  source = "./modules/browserless"
}

module "minecraft" {
  disabled = !var.install_minecraft

  source = "./modules/minecraft"
}

module "whiskers" {
  disabled = !var.install_whiskers

  source = "./modules/whiskers"
}

module "boundary" {
  disabled = !var.install_boundary

  source = "./modules/boundary"
}
