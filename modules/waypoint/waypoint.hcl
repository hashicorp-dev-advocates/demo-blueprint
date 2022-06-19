certificate_leaf "registry_leaf" {
  depends_on = ["copy.waypoint_root_ca"]

  ca_cert = "${var.cn_nomad_client_host_volume.source}/root.cert"
  ca_key  = "${var.cn_nomad_client_host_volume.source}/root.key"

  ip_addresses = ["10.5.0.100", "127.0.0.1"]
  dns_names    = ["registry.container.shipyard.run"]

  output = var.cn_nomad_client_host_volume.source
}

container "registry" {
  depends_on = ["certificate_leaf.registry_leaf"]

  network {
    name       = "network.dc1"
    ip_address = "10.5.0.100"
  }

  image {
    name = "registry:2"
  }

  volume {
    source      = var.cn_nomad_client_host_volume.source
    destination = "/certs"
  }

  env_var = {
    REGISTRY_HTTP_ADDR            = "0.0.0.0:443"
    REGISTRY_HTTP_TLS_CERTIFICATE = "/certs/registry_leaf.cert"
    REGISTRY_HTTP_TLS_KEY         = "/certs/registry_leaf.key"
  }

  port {
    local  = 443
    remote = 443
    host   = 1443
  }
}

exec_remote "waypoint_pack" {
  depends_on = ["nomad_cluster.local"]

  image {
    name = "shipyardrun/hashicorp-tools:v0.9.0"
  }

  network {
    name = "network.dc1"
  }

  cmd = "nomad-pack"
  args = [
    "run",
    "--var=waypoint_odr_additional_certs=\"${file("../../certs/root.cert")}\"",
    "/pack/nomad-pack-community-registry-main/packs/waypoint"
  ]

  # Mount a volume containing the config
  volume {
    source      = "${file_dir()}/../../pack"
    destination = "/pack"
  }

  volume {
    source      = var.cn_nomad_client_host_volume.source
    destination = "/scripts"
  }

  working_directory = "/pack"

  env {
    key   = "NOMAD_ADDR"
    value = "http://server.local.nomad-cluster.shipyard.run:4646"
  }
}

output "WAYPOINT_TOKEN" {
  value = "$(cat ${var.cn_nomad_client_host_volume.source}/waypoint.token)"
}

nomad_ingress "waypoint-ui" {
  cluster = var.cn_nomad_cluster_name
  job     = "waypoint-server"
  group   = "waypoint-server"
  task    = "server"

  network {
    name = "network.dc1"
  }

  port {
    local  = 9702
    remote = "ui"
    host   = 9702
  }
}

nomad_ingress "waypoint-server" {
  cluster = var.cn_nomad_cluster_name
  job     = "waypoint-server"
  group   = "waypoint-server"
  task    = "server"

  network {
    name = "network.dc1"
  }

  port {
    local  = 9701
    remote = "server"
    host   = 9701
  }
}
