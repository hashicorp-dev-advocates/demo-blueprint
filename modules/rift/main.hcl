variable "rift_version" {
  default = "v0.1.0"
}

variable "boundary_auth_method" {
  default = ""
}

template "generate_rift_config" {
  depends_on = ["module.boundary"]
  source     = <<-EOT
  #!/bin/bash -xe
  BOUNDARY_AUTH_METHOD=$(curl -s -H 'Content-Type: application/json' \
    http://boundary.container.shipyard.run:9200/v1/auth-methods?scope_id=global | \
    jq -r '.items[] | select(.name == "#{{ .Vars.auth_method }}") | .id'
  )

  BOUNDARY_TOKEN=$(curl -s -H 'Content-Type: application/json' -XPOST \
    http://boundary.container.shipyard.run:9200/v1/auth-methods/$${BOUNDARY_AUTH_METHOD}:authenticate -d '{
      "attributes": {
        "login_name": "#{{ .Vars.login_name }}",
        "password": "#{{ .Vars.password }}"
      },
      "token_type": null,
      "command": "login"
    }' | jq -r '.attributes.token'
  )

  BOUNDARY_ORGANIZATION=$(curl -s -H 'Content-Type: application/json' -H "Authorization: Bearer $${BOUNDARY_TOKEN}" \
    http://boundary.container.shipyard.run:9200/v1/scopes?scope_id=global | \
    jq -r '.items[] | select(.name == "#{{ .Vars.organization }}") | .id'
  )

  CONTACT_POINT=$(curl -m 30 -s -H 'Content-Type: application/json' -H 'Host: grafana.ingress.shipyard.run' -XPOST http://#{{ .Vars.grafana_url }}/api/v1/provisioning/contact-points -d '{
    "uid": "rift",
    "name": "rift",
    "type": "webhook",
    "settings": {
      "url": "http://${shipyard_ip()}/v1/alertmanager"
    },
    "disableResolveMessage": false
  }' | jq '.uid')
  echo "Created contact point for Rift: $${CONTACT_POINT}"

  cat <<EOF > /files/config.json
  {
    "pagerduty": {
      "enabled": false
    },
    "alertmanager": {
      "enabled": true
    },
    "boundary": {
      "organization": "$${BOUNDARY_ORGANIZATION}",
      "auth": {
        "method": "$${BOUNDARY_AUTH_METHOD}",
        "username": "#{{ .Vars.login_name }}",
        "password": "#{{ .Vars.password }}"
      }
    }
  }
  EOF
  EOT

  vars = {
    auth_method  = var.boundary_auth_method
    organization = var.boundary_organization
    login_name   = var.boundary_admin_login
    password     = var.boundary_admin_password
    grafana_url  = "admin:admin@ingress-http.nomad-ingress.shipyard.run:18080"
  }

  destination = "${data("rift")}/setup.sh"
}

exec_remote "generate_rift_config" {
  depends_on = ["template.generate_rift_config", "module.monitoring"]

  image {
    name = "shipyardrun/hashicorp-tools:v0.9.0"
  }

  network {
    name = "network.dc1"
  }

  cmd = "/bin/bash"
  args = [
    "/files/setup.sh"
  ]

  volume {
    source      = "${data("rift")}"
    destination = "/files"
  }
}

container "rift" {
  depends_on = ["exec_remote.generate_rift_config"]
  network {
    name = "network.${var.cn_network}"
  }

  image {
    name = "hashicraft/rift:${var.rift_version}"
  }

  port {
    local  = 4444
    remote = 4444
    host   = 4444
  }

  volume {
    source      = "${data("rift")}"
    destination = "/config"
  }

  env {
    key   = "BOUNDARY_ADDR"
    value = "http://boundary.container.shipyard.run:9200"
  }

  env {
    key   = "LOG_LEVEL"
    value = "debug"
  }
}