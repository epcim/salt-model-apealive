{% if 'wireguard' in pillar %}

{% if grains.kernel == 'Linux' %}

wireguard_packages:
  pkg.installed:
    - names:
        - wireguard
        {% if grains.get('machine_model', '').startswith('Raspberry Pi') %}
        - raspberrypi-kernel-headers
        {% endif %}

wireguard_generate_keys:
  cmd.run:
    {% if 'private_key' in pillar.wireguard %}
    - name: 'echo {{ pillar.wireguard.private_key }} > privatekey; echo {{ pillar.wireguard.public_key }} > publickey'
    {% else %}
    - name: 'umask 077; wg genkey | tee privatekey | wg pubkey > publickey'
    {% endif %}
    - shell: '/bin/bash'
    - cwd: /etc/wireguard
    - creates: /etc/wireguard/publickey
    - require:
        - wireguard_packages

wireguard_grain_pub_key:
  grains.present:
    - name: 'wireguard_publickey'
    - value: '{{ salt['cmd.shell']('cat /etc/wireguard/publickey') }}'
    - watch:
        - wireguard_generate_keys

wireguard_grain_interfaces:
  grains.present:
    - name: 'wireguard_interfaces'
    - value: 
        {% for interface in pillar.wireguard.interfaces %}
        {{ interface.name }}:
          addresses: {{ interface.addresses }}
          peers: []
        {% endfor %}
    - force: true
    - watch:
        - wireguard_generate_keys

{% for iface in pillar.wireguard.interfaces %}
wireguard_{{ iface.name }}_config_file:
  file.managed:
    - name: '/etc/wireguard/{{ iface.name }}.conf'
    - source: 'salt://wireguard/files/interface.conf'
    - user: root
    - template: jinja
    - defaults:
        pillar: {{ pillar }}
        iface_name: {{ iface.name }}
    - mode: 644
    - require:
        - wireguard_generate_keys

wireguard_{{ iface.name }}_service:
  service.running:
    - name: 'wg-quick@{{ iface.name }}'
    - enable: true
    - watch:
        - wireguard_{{ iface.name }}_config_file

{% endfor %}

{% endif %}

{% endif %}
