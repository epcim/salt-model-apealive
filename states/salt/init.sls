{% if 'salt' in pillar %}

{% if grains.kernel == 'Linux' %}

salt_minion_packages: 
  pkg.latest:
    - names:
        - salt-minion
        - python3-usb

salt_minion_config_file:
  file.managed:
    - name: '/etc/salt/minion.d/minion.conf'
    - source: 'salt://salt/files/minion.conf'
    - user: 'root'
    - mode: 644
    - template: jinja
    - defaults:
        pillar: {{ pillar }}
    - require:
        - 'salt_minion_packages'

salt_minion_unit_service:
  service.running:
    - name: salt-minion
    - enable: true
    - watch:
        - 'salt_minion_config_file'

{% endif %}

{% endif %}