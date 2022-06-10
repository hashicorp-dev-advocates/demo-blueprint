exec_remote "generate_certs" {
  image {
    name = "shipyardrun/tools:v0.7.0"
  }

  cmd = "shipyard"
  args = [
    "connector",
    "generate-certs",
    "--leaf",
    "--root-ca",
    "./root.cert",
    "--root-key",
    "./root.key",
    "--dns-name",
    "127.0.0.1:9443",
    ".",
  ]

  working_directory = "/data"

  volume {
    source      = data("waypoint_data")
    destination = "/data"
  }

  volume {
    source      = "${shipyard()}/certs"
    destination = "/certs"
  }
}