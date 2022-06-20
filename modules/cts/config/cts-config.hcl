log_level   = "INFO"
working_dir = "."
port        = 8558

syslog {}

buffer_period {
  enabled = true
  min     = "5s"
  max     = "20s"
}

consul {
  address = "consul.container.shipyard.run:8500"
}

driver "terraform" {
  # version = "0.14.0"
  # path = ""
  log         = false
  persist_log = false

  backend "consul" {
    gzip = true
  }
}

task {
 name        = "cts-boundary"
 module      = "/consul-terraform-sync/config/terraform"
 condition "services" {
  names = ["payments", "api"]
 }
}
