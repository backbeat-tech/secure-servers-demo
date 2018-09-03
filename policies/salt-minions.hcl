path "secret/*" {
  capabilities = ["read", "list"]
}

path "sys/policy/*" {
  capabilities = ["read", "list", "create", "update", "delete"]
}
