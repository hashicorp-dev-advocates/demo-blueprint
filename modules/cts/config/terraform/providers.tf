provider "boundary" {
  addr = var.boundary_address

  auth_method_id                  = data.terraform_remote_state.boundary.auth_method_id
  password_auth_method_login_name = "admin"
  password_auth_method_password   = "password"
}