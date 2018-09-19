database_backend:
  ss_vault.database_backend_enabled:
    - name: database

postgres_connection:
  ss_vault.postgres_database_enabled:
    - name: secure-servers
    {% raw %}
    - connection_url: "postgresql://{{username}}:{{password}}@127.0.0.1:5432/secure-servers"
    {% endraw %}
    - allowed_roles: "read-only"
    - username: vault
    - password: complex_p$ssw0rd

readonly_role:
  ss_vault.postgres_role_enabled:
    - name: guest
    - db_name: secure-servers
    # can login for 5 minutes by default, lease renewable up to 1hr
    - default_ttl: 300
    - max_ttl: 3600
