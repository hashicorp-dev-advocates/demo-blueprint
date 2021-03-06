module "boundary_install" {
  source = "github.com/devops-rob/shipyard-blueprints?ref=fbe41a3661166f0599ec3c75fa8fc8617fe01cfd/modules//boundary"
}

variable "boundary_version" {
  default = "0.8.0"
}

variable "network" {
  default = var.cn_network
}

exec_remote "boundary-setup" {
  depends_on = ["module.boundary_install"]

  image {
    name = "shipyardrun/hashicorp-tools:v0.9.0"
  }

  network {
    name = "network.dc1"
  }

  cmd = "/bin/bash"
  args = [
    "/config/config.sh"
  ]

  # Mount a volume containing the config
  volume {
    source      = "./config"
    destination = "/config"
  }

  working_directory = "/"

  env {
    key   = "BOUNDARY_ADDR"
    value = "http://boundary.container.shipyard.run:9200"
  }
}