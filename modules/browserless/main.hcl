container "browserless" {
  network {
    name = "network.dc1"
  }

  image {
    name = "browserless/chrome:latest"
  }

  env {
    key   = "MAX_CONCURRENT_SESSIONS"
    value = "10"
  }
}

container "app" {
  network {
    name = "network.dc1"
  }

  image {
    name = "nicholasjackson/browserless-app:latest"
  }

  env {
    key   = "BROWSERLESS"
    value = "ws://browserless.container.shipyard.run:3000"
  }

  port {
    local  = "8080"
    host   = "28080"
    remote = "8080"
  }
}