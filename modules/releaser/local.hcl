output "TLS_CERT" {
  value = "${var.cn_nomad_client_host_volume.source}/releaser_leaf.cert"
}

output "TLS_KEY" {
  value = "${var.cn_nomad_client_host_volume.source}/releaser_leaf.key"
}

nomad_job "controller-local" {
  disabled = var.install_controller != "local"

  cluster = var.cn_nomad_cluster_name
  paths = [
    "./jobs/controller.hcl",
  ]
}

nomad_ingress "controller-local" {
  disabled = var.install_controller != "local"

  cluster = var.cn_nomad_cluster_name
  job     = "release-controller"
  group   = "release-controller"
  task    = "socat"

  network {
    name = "network.dc1"
  }

  port {
    local  = 8080
    remote = "http"
    host   = 18080
  }
}