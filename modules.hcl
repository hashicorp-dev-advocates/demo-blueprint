network "dc1" {
  subnet = "10.5.0.0/16"
}

module "consul_nomad" {
  depends_on = ["container.waypoint-odr"]
  source     = "github.com/shipyard-run/blueprints?ref=d9446bfc97759e66b82b1fed60fd70c94ab98238/modules//consul-nomad"
}

module "monitoring" {
  depends_on = ["module.consul_nomad"]
  disabled   = !var.install_monitoring

  source = "./modules/monitoring"
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
  depends_on = ["module.consul_nomad"]
  disabled   = var.install_controller == ""

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

#module "boundary" {
#  disabled = var.install_controller == ""
#
#  source = "./modules/releaser"
#}
