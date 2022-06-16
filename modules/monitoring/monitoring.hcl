template "grafana_config" {

  source = <<-EOF
    upstreams = [{
      name = "prometheus"
      port = 9090
      },
      {
        name = "loki"
        port = 3100
    }]

    dashboards = [{
      name = "payments"
      data = <<EOT
      ${file("../example_app/jobs/payments-dashboard.json")}
      EOT
    }]

    custom_config = <<-EOT
      [auth.anonymous]
      enabled = true

      # Organization name that should be used for unauthenticated users
      org_name = Main Org.

      # Role for unauthenticated users, other valid values are `Editor` and `Admin`
      org_role = Viewer

      # Hide the Grafana version text from the footer and help tooltip for unauthenticated users (default: false)
      hide_version = true
    EOT

  EOF

  destination = "${data("monitoring_data")}/grafana.hcl"
}

template "monitoring_pack" {
  source = <<-EOF
    #!/bin/bash -e

    nomad-pack run -f /pack/prometheus-pack.hcl /pack/nomad-pack-community-registry-main/packs/prometheus
    nomad-pack run -f /scripts/grafana.hcl /pack/nomad-pack-community-registry-main/packs/grafana
    nomad-pack run -f /pack/loki.hcl /pack/nomad-pack-community-registry-main/packs/loki
  EOF

  destination = "${data("monitoring_data")}/install_monitoring.sh"
}

exec_remote "pack" {
  depends_on = ["nomad_cluster.local", "template.monitoring_pack", "template.grafana_config"]

  image {
    name = "shipyardrun/hashicorp-tools:v0.9.0"
  }

  network {
    name = "network.dc1"
  }

  cmd = "/bin/bash"
  args = [
    "/scripts/install_monitoring.sh"
  ]

  # Mount a volume containing the config
  volume {
    source      = "${file_dir()}/../../pack"
    destination = "/pack"
  }

  volume {
    source      = data("monitoring_data")
    destination = "/scripts"
  }

  working_directory = "/pack"

  env {
    key   = "NOMAD_ADDR"
    value = "http://server.local.nomad-cluster.shipyard.run:4646"
  }
}