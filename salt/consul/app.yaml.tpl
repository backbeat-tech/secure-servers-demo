app:
    quality_level: {{key "quality_level"}}
    password: {{ with secret "secret/password" }}{{ .Data.value }}{{ end }}
