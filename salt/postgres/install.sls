postgres:
  pkg.installed:
    - names:
      - postgresql-9.6
      - postgresql-client-9.6
  postgres_database.present:
    - name: secure-servers
    - require:
      - pkg: postgres
  postgres_user.present:
    - name: vault
    - superuser: True
    - password: complex_password
    - require:
      - pkg: postgres
