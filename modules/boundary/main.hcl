module "boundary" {
    source = "github.com/devops-rob/shipyard-blueprints/modules//boundary"
}

variable "boundary_version" {
  default = "0.8.0"
}

variable "network" {
  default = var.cn_network
}

# exec_remote "boundary-configure" {
#     image  {
#         name = "hashicorp/boundary:${var.boundary_version}"
#     }

#     cmd = "boundary"
#     args = [
#         "database",
#         "init",
#         #"-skip-target-creation",
#         #"-skip-scopes-creation",
#         #"-skip-host-resources-creation",
#         #"-skip-auth-method-creation",
#         "-config=/boundary/config.hcl"
#     ]


#     env {
#         key = "BOUNDARY_POSTGRES_URL"
#         value = "postgresql://${var.boundary_postgres_user}:${var.boundary_postgres_password}@postgres.container.shipyard.run:5432/postgres?sslmode=disable"
#     }

#     network {
#         name = "network.${var.network}"
#     }

#     volume {
#     source = data("boundary")
#     destination = "/boundary"
#   }

#     depends_on = [
#         "container.postgres",
#         "exec_remote.psql_checker"
#     ]

# }

# Full example can be found at /examples/exec_remote/exec_stand_alone

# exec_remote "exec_standalone" {
#   depends_on = ["container.boundary"]

#   image {
#     name = "hashicorp/boundary:${var.boundary_version}"
#   }
  
#   network {
#     name = var.cn_network
#   }

#   cmd = "consul"
#   args = [
#     "services",
#     "register",
#     "/config/redis.hcl"
#   ]

#   # Mount a volume containing the config
#   volume {
#     source = "./config"
#     destination = "/config"
#   }

# }