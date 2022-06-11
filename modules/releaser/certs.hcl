certificate_leaf "releaser_leaf" {
  depends_on = ["copy.waypoint_root_ca"]

  ca_cert = "${var.cn_nomad_client_host_volume.source}/root.cert"
  ca_key  = "${var.cn_nomad_client_host_volume.source}/root.key"

  ip_addresses = ["127.0.0.1"]
  dns_names    = ["127.0.0.1:9443"]

  output = var.cn_nomad_client_host_volume.source
}