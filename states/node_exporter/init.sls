{% if 'node_exporter' in pillar %}

{% set meta = pillar.node_exporter %}

{% if grains.cpuarch|lower == "x86_64" %}
{% set cpu_arch = "amd64" %}
{% else %}
{% set cpu_arch = grains.cpuarch|lower %}
{% endif %}

{% if grains.kernel == 'Linux' %}

node_exporter_user:
  user.present:
    - name: node_exporter
    - system: true
    - home: /var/lib/node_exporter

node_exporter_dir:
  file.directory:
    - name: /var/lib/node_exporter/textfile_collector
    - makedirs: true
    - user: node_exporter

node_exporter_sysconfig_file:
  file.managed:
    - name: '/etc/sysconfig/node_exporter'
    - source: 'salt://node_exporter/files/sysconfig.node_exporter'
    - user: 'root'
    - makedirs: true
    - mode: 644
    - template: jinja
    - defaults:
        pillar: {{ pillar }}

node_exporter_service_file:
  file.managed:
    - name: '/etc/systemd/system/node-exporter.service'
    - source: 'salt://node_exporter/files/node-exporter.service'
    - user: 'root'
    - makedirs: true
    - mode: 644
    - template: jinja
    - defaults:
        pillar: {{ pillar }}

node_exporter_binary_unpack:
  archive.extracted:
    - name: /root
    - skip_verify: true
    - source: https://github.com/prometheus/node_exporter/releases/download/v{{ meta.source.version }}/node_exporter-{{ meta.source.version }}.{{ grains.kernel|lower }}-{{ cpu_arch }}.tar.gz
    - if_missing: /root/node_exporter-{{ meta.source.version }}.{{ grains.kernel|lower }}-{{ cpu_arch }}

node_exporter_binary:
  file.managed:
    - name: '/usr/sbin/node_exporter'
    - source: 'file:////root/node_exporter-{{ meta.source.version }}.{{ grains.kernel|lower }}-{{ cpu_arch }}/node_exporter'
    - user: 'root'
    - mode: 777
    - require:
        - node_exporter_binary_unpack

node_exporter_unit_service:
  service.running:
    - name: node-exporter
    - enable: true
    - watch:
        - node_exporter_sysconfig_file
        - node_exporter_service_file
        - node_exporter_binary

{% endif %}

{% endif %}
