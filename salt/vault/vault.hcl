storage "file" {
  path = "/var/vault/data"
}

listener "tcp" {
  address = "127.0.0.1:8200"
  tls_cert_file = "/etc/pki/vault.crt"
  tls_key_file  = "/etc/pki/vault.key"
}
