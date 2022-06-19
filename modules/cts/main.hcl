variable "cts_version" {
    default = "0.6"
}

container "cts" {
    network {
        name = "network.${var.cn_network}"
    }

    image {
        name = "hashicorp/consul-terraform-sync:${var.cts_version}"
    }

    volume {
        source      = "./config"
        destination = "/consul-terraform-sync/config"
    }

    port {
        local  = 8558
        remote = 8558
        host   = 8558
    }

    # env {
    #     key   = "CONSUL_HTTP_ADDR"
    #     value = "consul.container.shipyard.run:18500"
    # }

}
