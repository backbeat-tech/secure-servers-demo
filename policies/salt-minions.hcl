path "secret/*" {
  capabilities = ["read", "list"]
}

path "sys/policy/*" {
  capabilities = ["read", "list", "create", "update", "delete"]
}

path "sys/mounts/*" {
  capabilities = ["read", "list", "create", "update", "delete"]
}

path "database/*" {
  capabilities = ["read", "list", "create", "update", "delete"]
}
