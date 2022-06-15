template "whiskers_pack" {
  source = <<-EOF
    #!/bin/bash -e
    nomad-pack run /pack/nomad-pack-community-registry-main/packs/finicky_whiskers
  EOF

  destination = "${data("whiskers")}/install_whiskers.sh"
}

exec_remote "whiskers_pack" {
  depends_on = ["nomad_cluster.local", "template.whiskers_pack"]

  image {
    name = "shipyardrun/hashicorp-tools:v0.8.0"
  }

  network {
    name = "network.dc1"
  }

  cmd = "/bin/bash"
  args = [
    "/scripts/install_whiskers.sh"
  ]

  # Mount a volume containing the config
  volume {
    source      = "${file_dir()}/../../pack"
    destination = "/pack"
  }

  volume {
    source      = data("whiskers")
    destination = "/scripts"
  }

  working_directory = "/pack"

  env {
    key   = "NOMAD_ADDR"
    value = "http://server.local.nomad-cluster.shipyard.run:4646"
  }
}