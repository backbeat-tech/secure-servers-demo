{% set vault_version = '0.10.4' %}

vault:
  archive.extracted:
    - name: /usr/local/bin/
    - source: https://releases.hashicorp.com/vault/{{vault_version}}/vault_{{vault_version}}_linux_amd64.zip
    - source_hash: https://releases.hashicorp.com/vault/{{vault_version}}/vault_{{vault_version}}_SHA256SUMS
    - archive_format: zip
    - if_missing: /usr/local/bin/vault
    - source_hash_update: True
    - enforce_toplevel: False
  file.managed:
    - name: /usr/local/bin/vault
    - mode: '0755'
    - require:
      - archive: vault

vault_config:
  file.managed:
    - name: /etc/vault.hcl
    - mode: '0755'
    - source: salt://vault/vault.hcl

vault_user:
  group.present:
    - name: vault
  user.present:
    - name: vault
    - fullname: Hashicorp Vault Server
    - shell: /usr/sbin/nologin
    - groups:
        - vault

vault_data_dir:
  file.directory:
    - name: /var/vault
    - user: vault
    - group: vault
    - mode: '0700'

vault_mlock_grant:
  pkg.installed:
    - name: libcap2-bin
  cmd.run:
    - name: 'setcap cap_ipc_lock=+ep /usr/local/bin/vault'
    - unless: 'systemctl status vault > /dev/null'
    - require:
        - pkg: vault_mlock_grant

vault_service:
  file.managed:
    - name: /etc/systemd/system/vault.service
    - mode: '0700'
    - source: salt://vault/vault.service
    - require:
        - user: vault_user
        - file: vault_config
  service.running:
    - name: vault
  cmd.run:
    - name: 'systemctl reload vault'
    - onchanges:
      - file: vault_config
      - file: vault_service
      - x509: vault_ssl_cert

vault_ssl_key:
  x509.private_key_managed:
    - name: /etc/pki/vault.key
    - bits: 4096
    - user: vault
    - group: vault
    - mode: 0700

vault_ssl_cert:
  x509.certificate_managed:
    - name: /etc/pki/vault.crt
    - public_key: /etc/pki/vault.key
    - signing_cert: /etc/pki/root.crt
    - signing_private_key: /etc/pki/root.key
    - CN: 'vault.local'
    - subjectAltName: 'IP:127.0.0.1'
    - user: vault
    - group: vault
    - mode: 0400
    - append_certs:
        - /etc/pki/root.crt
    - require:
      - x509: vault_ssl_key
