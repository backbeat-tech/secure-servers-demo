{% set version = '0.20.0' %}

consul_template:
  archive.extracted:
    - name: /tmp/consul-template
    - enforce_toplevel: False
    - source: https://releases.hashicorp.com/consul-template/{{version}}/consul-template_{{version}}_linux_amd64.zip
    - source_hash: https://releases.hashicorp.com/consul-template/{{version}}/consul-template_{{version}}_SHA256SUMS
    - unless: test -f /usr/local/bin/consul-template
  file.managed:
    - name: /usr/local/bin/consul-template
    - source: /tmp/consul-template/consul-template
    - mode: 0755
    - unless: test -f /usr/local/bin/consul-template
    - require:
      - archive: consul_template

consul_template_config:
  file.managed:
    - name: /etc/consul-template.hcl
    - source: salt://consul/consul-template.hcl

consul_template_app_template:
  file.managed:
    - name: /etc/app.yaml.tpl
    - source: salt://consul/app.yaml.tpl

consul_template_service:
  file.managed:
    - name: /etc/systemd/system/consul-template.service
    - source: salt://consul/consul-template.service
  service.running:
    - name: consul-template
    - enable: True
    - require:
      - file: consul_template
      - file: consul_template_config
      - file: consul_template_app_template
      - file: consul_template_service
    - watch:
      - file: consul_template
      - file: consul_template_config
      - file: consul_template_app_template
      - file: consul_template_service
