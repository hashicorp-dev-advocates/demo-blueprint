# script to download custom waypoint plugins and add them to the odr image
template "download_plugin" {
  source = <<-EOF
    # Determine the OS and architecure
    ARCH=$(uname -m)
    SHIPYARD_ARCH="amd64"

    if [ "$${ARCH}" == "x86_64" ]; then
      SHIPYARD_ARCH="amd64"
    fi

    if [ "$${ARCH}" == "arm64" ]; then
      SHIPYARD_ARCH="arm64"
    fi

    wget --no-check-certificate https://github.com/hashicorp-dev-advocates/waypoint-plugin-noop/releases/download/v0.2.2/waypoint-plugin-noop_linux_$${SHIPYARD_ARCH}.zip && \
      unzip waypoint-plugin-noop_linux_$${SHIPYARD_ARCH}.zip
  EOF

  destination = "${var.cn_nomad_client_host_volume.source}/download_plugin.sh"
}

# build a custom waypoint ODR image that contains the insecure registry certs
template "waypoint_odr" {
  source = <<-EOF
    FROM alpine:latest as setup

    RUN apk --no-cache add ca-certificates \
      && update-ca-certificates

    COPY ./root.cert  /registry.pem
    RUN cat /registry.pem >> /etc/ssl/certs/ca-certificates.crt

    COPY ./download_plugin.sh /download_plugin.sh
    RUN sh /download_plugin.sh

    FROM hashicorp/waypoint-odr:latest
    SHELL ["/kaniko/bin/sh", "-c"]

    ENV HOME /root
    ENV USER root
    ENV PATH="$${PATH}:/kaniko"
    ENV SSL_CERT_DIR=/kaniko/ssl/certs
    ENV DOCKER_CONFIG /kaniko/.docker/
    ENV XDG_CONFIG_HOME=/kaniko/.config/
    ENV TMPDIR /kaniko/tmp
    ENV container docker

    COPY --from=setup /etc/ssl/certs/ca-certificates.crt /kaniko/ssl/certs/ca-certificates.crt

    #RUN mkdir -p /kaniko/.config/waypoint/plugins/
    COPY --from=setup /waypoint-plugin-noop /kaniko/.config/waypoint/plugins/waypoint-plugin-noop
  EOF

  destination = "${var.cn_nomad_client_host_volume.source}/Dockerfile.odr"
}


# If this tag is updated then the waypoint-server job needs the corresponding change
variable "waypoint_odr_tag" {
  default = "0.0.7"
}

# Build a custom ODR with our certs
container "waypoint-odr" {
  disabled   = true
  depends_on = ["copy.waypoint_root_ca"]

  network {
    name = "network.dc1"
  }

  build {
    file    = "./Dockerfile.odr"
    context = var.cn_nomad_client_host_volume.source
    tag     = var.waypoint_odr_tag
  }

  command = ["/kaniko/waypoint"]
}

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
