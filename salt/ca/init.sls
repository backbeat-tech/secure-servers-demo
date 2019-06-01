ca_x509_module:
  pkg.installed:
    - name: python-m2crypto
    - reload_modules: True

ca_root_key:
  file.directory:
    - name: /etc/pki
    - mode: 0755
  x509.private_key_managed:
    - name: /etc/pki/root.key
    - bits: 4096
    - require:
      - pkg: ca_x509_module
      - file: ca_root_key

ca_root_cert:
  x509.certificate_managed:
    - name: /etc/pki/root.crt
    - signing_private_key: /etc/pki/root.key
    - CN: {{grains['id']}}
    - basicConstraints: "critical CA:true"
    - keyUsage: "critical cRLSign, keyCertSign"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - require:
      - x509: ca_root_key

ca_trust_root_cert:
  file.managed:
    - name: /usr/local/share/ca-certificates/root.crt
    - source: /etc/pki/root.crt
    - makedirs: True
  cmd.run:
    - name: 'update-ca-certificates --fresh'
    - onchanges:
      - file: ca_trust_root_cert
