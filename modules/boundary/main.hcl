module "boundary" {
    source = "github.com/devops-rob/shipyard-blueprints/modules//boundary"
}

variable "boundary_version" {
  default = "0.8.0"
}

variable "network" {
  default = var.cn_network
}

exec_remote "boundary-setup" {
  depends_on = ["module.boundary"] # fix this

  image {
    name = "shipyardrun/hashicorp-tools:v0.8.0"
  }

  network {
    name = "network.dc1"
  }

  cmd = "/bin/bash"
  args = [
    "./config.sh"
  ]

  # Mount a volume containing the config
  volume {
    source      = data("config")
    destination = "/config"
  }

  working_directory = "/config"

  env {
    key   = "BOUNDARY_ADDR"
    value = "http://boundary.shipyard.run:9200"
  }
}