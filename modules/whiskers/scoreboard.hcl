container "scoreboard" {
  network {
    name = "network.dc1"
  }

  image {
    name = "hashicraft/finicky-scoreboard:v0.0.3"
  }

  port {
    local  = 4000
    remote = 4000
    host   = 4000
  }
}