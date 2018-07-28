vault_policy_read_only:
  vault.policy_present:
    - name: read-only
    - rules: |
        path "*" {
          capabilities = ["read", "list"]
        }
