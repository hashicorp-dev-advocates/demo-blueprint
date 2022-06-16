container "scoreboard" {
  network {
    name = "network.dc1"
  }

  image {
    name = "hashicraft/finicky-scoreboard:v0.0.2"
  }

  port {
    local  = 8080
    remote = 8080
    host   = 4000
  }
}