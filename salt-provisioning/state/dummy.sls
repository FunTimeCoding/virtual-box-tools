# {% set greeting = pillar['greeting'] %}
root_readme:
  file.managed:
    - name: /root/salt-example.md
    - source: salt://salt-example.md
    - template: jinja
    - context:
      greeting: {{ greeting }}
