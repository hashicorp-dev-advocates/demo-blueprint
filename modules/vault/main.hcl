variable "vault_bootstrap_script" {
  default = <<-EOF
  #/bin/sh -e
  vault status

  vault secrets enable kv-v2
  vault kv put secret/minecraft/level-1 access=true
  vault kv put secret/minecraft/level-2 access=true
  vault kv put secret/minecraft/level-3 access=true
  vault kv put secret/minecraft/level-4 access=true
  vault kv put secret/minecraft/incident-response access=true

  vault auth enable userpass

  vault policy write level-1 /data/policies/level-1.hcl
  vault policy write level-2 /data/policies/level-2.hcl
  vault policy write level-3 /data/policies/level-3.hcl
  vault policy write level-4 /data/policies/level-4.hcl
  vault policy write incident-response /data/policies/incident-response.hcl
  EOF
}

copy "vault_policies" {
  source      = "${file_dir()}/policies"
  destination = "${data("vault_data")}/policies"
}

variable "vault_network" {
  default = var.cn_network
}

module "vault" {
  depends_on = ["copy.vault_policies"]
  source     = "github.com/shipyard-run/blueprints?ref=f235847a73c5bb81943aaed8f0c526edee693d75/modules//vault-dev"
}

output "VAULT_ADDR" {
  value = "http://localhost:8200"
}

output "VAULT_TOKEN" {
  value = "root"
}