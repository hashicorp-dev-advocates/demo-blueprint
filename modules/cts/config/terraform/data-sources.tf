data "terraform_remote_state" "boundary" {
  backend = "consul"
  config = {
    path    = "full/path" # Update this to Consul k/v path
    address = "consul.container.shipyard.run:8500"
  }
}