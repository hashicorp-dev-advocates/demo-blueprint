job "ingress" {

  datacenters = ["dc1"]

  constraint {
    attribute = "${attr.unique.hostname}"
    value     = "1.client.local"
  }

  group "ingress" {

    network {
      mode = "bridge"
      port "http" {
        static = 18080
        to     = 18080
      }

      port "grafana" {
        static = 18081
        to     = 18081
      }

      port "prometheus" {
        static = 18082
        to     = 18082
      }

      port "releaser" {
        static = 18083
        to     = 18083
      }

      port "whiskers" {
        static = 18084
        to     = 18084
      }

      port "metrics" {
        to = "9102"
      }
    }

    service {
      name = "ingress-grafana"
      port = "grafana"
    }

    service {
      name = "ingress-prometheus"
      port = "prometheus"
    }

    service {
      name = "ingress-releaser"
      port = "releaser"
    }

    service {
      name = "ingress-whiskers"
      port = "whiskers"
    }

    service {
      name = "ingress-metrics"
      port = "metrics"
      tags = ["metrics"]
      meta {
        metrics    = "prometheus"
        job        = "${NOMAD_JOB_NAME}"
        datacenter = "${node.datacenter}"
      }
    }

    service {
      name = "ingress"
      port = "18080"

      connect {
        gateway {
          proxy {
            # expose the metrics endpont 
            config {
              envoy_prometheus_bind_addr = "0.0.0.0:9102"
            }
          }

          ingress {
            listener {
              port     = 18080
              protocol = "http"

              service {
                name  = "grafana"
                hosts = ["grafana.ingress.shipyard.run", "grafana.hashiconf.hashicraft.com"]
              }

              service {
                name  = "prometheus"
                hosts = ["prometheus.ingress.shipyard.run", "prometheus.hashiconf.hashicraft.com"]
              }

              service {
                name  = "consul-release-controller"
                hosts = ["releaser.ingress.shipyard.run", "releaser.hashiconf.hashicraft.com"]
              }

              service {
                name  = "finicky-whiskers"
                hosts = ["whiskers.ingress.shipyard.run", "whiskers.hashiconf.hashicraft.com"]
              }

              service {
                name  = "api"
                hosts = ["*"]
              }
            }

            listener {
              port     = 18081
              protocol = "http"

              service {
                name  = "grafana"
                hosts = ["*"]
              }
            }

            listener {
              port     = 18082
              protocol = "http"

              service {
                name  = "prometheus"
                hosts = ["*"]
              }
            }

            listener {
              port     = 18083
              protocol = "http"

              service {
                name  = "consul-release-controller"
                hosts = ["*"]
              }
            }

            listener {
              port     = 18084
              protocol = "http"

              service {
                name  = "finicky-whiskers"
                hosts = ["*"]
              }
            }
          }
        }
      }
    }
  }
}