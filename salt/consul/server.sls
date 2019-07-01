{% set consul_version = '1.5.2'  %}

consul:
  archive.extracted:
    - name: /tmp/consul
    - enforce_toplevel: False
    - source: 'https://releases.hashicorp.com/consul/{{consul_version}}/consul_{{consul_version}}_linux_amd64.zip'
    - source_hash: 'https://releases.hashicorp.com/consul/{{consul_version}}/consul_{{consul_version}}_SHA256SUMS'
    - unless: test -f /usr/local/bin/consul
  file.managed:
    - name: /usr/local/bin/consul
    - source: /tmp/consul/consul
    - mode: 0755
    - unless: test -f /usr/local/bin/consul
    - require:
      - archive: consul
  group.present:
    - name: consul
  user.present:
    - name: consul
    - fullname: Hashicorp Consul
    - shell: /usr/bin/nologin
    - groups:
        - consul

consul_data_dir:
  file.directory:
    - name: /var/consul
    - user: consul
    - group: consul
    - mode: 0750

consul_config:
  file.managed:
    - name: /etc/consul.json
    - source: salt://consul/config.json
    - user: consul
    - group: consul
    - mode: 0640

consul_ssl_key:
  x509.private_key_managed:
    - name: /etc/pki/consul.key
    - bits: 4096
    - user: consul
    - group: consul
    - mode: 0700

consul_ssl_cert:
  x509.certificate_managed:
    - name: /etc/pki/consul.crt
    - public_key: /etc/pki/consul.key
    - signing_cert: /etc/pki/root.crt
    - signing_private_key: /etc/pki/root.key
    - CN: 'consul.local'
    - subjectAltName: 'IP:127.0.0.1'
    - user: consul
    - group: consul
    - mode: 0400
    - append_certs:
        - /etc/pki/root.crt
    - require:
      - x509: consul_ssl_key

consul_service:
  file.managed:
    - name: /etc/systemd/system/consul.service
    - source: salt://consul/consul.service
  service.running:
    - name: consul
    - enable: True
    - require:
      - file: consul
      - file: consul_config
      - file: consul_service
      - x509: consul_ssl_cert
    - watch:
      - file: consul
      - file: consul_service
      - file: consul_config
      - x509: consul_ssl_cert
