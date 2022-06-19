module "boundary_install" {
  source = "github.com/devops-rob/shipyard-blueprints?ref=fbe41a3661166f0599ec3c75fa8fc8617fe01cfd/modules//boundary"
}

variable "boundary_version" {
  default = "0.8.0"
}

variable "network" {
  default = var.cn_network
}

template "boundary_setup" {
  source = <<-EOT
  #!/bin/bash

  # Create an auth method
  AUTH_METHOD_ID=$(boundary auth-methods create password \
    -name="#{{ .Vars.boundary_auth_method }}" \
    -description="auth method for global scope" \
    -scope-id=global \
    -recovery-config="/files/recovery.hcl" \
    -format="json" | jq -r '.item.id')

  # Create Account
  ACCOUNT_ID=$(boundary accounts create password -login-name=#{{ .Vars.boundary_admin_login }} \
    -description "Password account for admin user" \
    -password="#{{ .Vars.boundary_admin_password }}" \
    -auth-method-id=$${AUTH_METHOD_ID} \
    -recovery-config="/files/recovery.hcl" \
    -format="json" | jq -r '.item.id')

  # create user
  USER_ID=$(boundary users create -name="#{{ .Vars.boundary_admin_user }}" \
    -description="admin user for global scope" \
    -recovery-config="/files/recovery.hcl" \
    -format="json" | jq -r '.item.id')

  # Add account to user
  boundary users set-accounts \
    -account=$${ACCOUNT_ID} \
    -id=$${USER_ID} \
    -version=1 \
    -recovery-config="/files/recovery.hcl" \
    -format="json" | jq 

  # Create admin role
  ROLE_ID=$(boundary roles create -name="#{{ .Vars.boundary_admin_role }}" \
    -scope-id="global" \
    -description="admin role for global scope" \
    -grant-scope-id="global" \
    -recovery-config="/files/recovery.hcl" \
    -format="json" | jq -r '.item.id')

  # Add grant strings
  boundary roles add-grants \
    -grant="id=*;type=*;actions=*" \
    -id=$${ROLE_ID} \
    -recovery-config="/files/recovery.hcl" \
    -format="json" | jq

  #Add user to role
  boundary roles add-principals \
    -id=$${ROLE_ID} \
    -principal=$${USER_ID} \
    -recovery-config="/files/recovery.hcl" \
    -format="json" | jq
  EOT

  vars = {
    boundary_auth_method    = var.boundary_auth_method
    boundary_admin_user     = var.boundary_admin_user
    boundary_admin_role     = var.boundary_admin_role
    boundary_admin_login    = var.boundary_admin_login
    boundary_admin_password = var.boundary_admin_password
  }

  destination = "${data("boundary_setup")}/setup.sh"
}

template "boundary_recovery" {
  source      = <<-EOT
  kms "aead" {
    purpose = "recovery"
    aead_type = "aes-gcm"
    key = "nIRSASgoP91KmaEcg/EAaM4iAkksyB+Lkes0gzrLIRM="
    key_id = "global_recovery"
  }
  EOT
  destination = "${data("boundary_setup")}/recovery.hcl"
}

exec_remote "boundary-setup" {
  depends_on = ["module.boundary_install", "template.boundary_setup", "template.boundary_recovery"]

  image {
    name = "shipyardrun/hashicorp-tools:v0.9.0"
  }

  network {
    name = "network.dc1"
  }

  cmd = "/bin/bash"
  args = [
    "/files/setup.sh"
  ]

  working_directory = "/"

  volume {
    source      = "${data("boundary_setup")}"
    destination = "/files"
  }

  env {
    key   = "BOUNDARY_ADDR"
    value = "http://boundary.container.shipyard.run:9200"
  }
}