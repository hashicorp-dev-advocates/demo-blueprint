locals {
  # Group service instances by service name
  consul_services = {
    for id, s in var.services : s.name => s...
  }
}

module "boundary_resources" {
  for_each = var.services

  source           = "hashicorp-dev-advocates/cts/boundary"
  version          = "1.0.0"
  project_scope_id = data.terraform_remote_state.boundary.project_scope_id
  service_name     = each.value["name"]
  service_address  = each.value["address"]
  service_port     = each.value["port"]
}