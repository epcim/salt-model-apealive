{% if 'linux' in pillar %}

{% if grains.kernel == 'Linux' %}

{% set use_wifi = false %}
{% for iface in pillar.linux.interfaces %}
{% if 'wireless_essid' in iface %}
{% set use_wifi = true %}
{% endif %}
{% endfor %}

linux_system_core_packages:
  pkg.installed:
    - names:
        - apt-transport-https
        - ca-certificates
        - software-properties-common
        - gnupg2

linux_system_hostname_file:
  file.managed:
    - name: /etc/hostname
    - contents: {{ pillar.linux.hostname }}
    - user: 'root'
    - group: 'root'
    - mode: 644

linux_system_linux_hostname_enforce: 
  cmd.wait:
    - name: 'hostname {{ pillar.linux.hostname }}'
    - unless: 'test "$(hostname)" = "{{ pillar.linux.hostname }}"'
    - watch:
        - linux_system_hostname_file

linux_ssh_service:
  service.running:
    - name: ssh
    - enable: true

{% if pillar.linux.swap.kind == 'none' %}

linux_system_swap_off_enforce:
  cmd.run:
    - name: 'swapoff -a'
    - unless: 'test "$(cat /proc/swaps | wc -l)" > "1"'

linux_system_no_fstab_swap:
  file.line:
    - name: '/etc/fstab'
    - mode: 'delete'
    - match: '.+( |\t)swap( |\t).+'
    - watch:
        - linux_system_swap_off_enforce

{% endif %}

{% if grains.get('machine_model', '').startswith('Raspberry Pi') %}

linux_system_no_dphys_swap:
  cmd.run:
    - name: 'dphys-swapfile swapoff && dphys-swapfile uninstall && systemctl disable dphys-swapfile'
    - onlyif: 'command -v dphys-swapfile && test "$(cat /proc/swaps | wc -l)" != "1"'
    - watch:
        - linux_system_swap_off_enforce

{% if use_wifi or not grains.get('machine_model', '').startswith('Raspberry Pi 2') %}

linux_system_wifi_packages:
  pkg.installed:
    - names:
        - iw
        - wireless-tools
        - wpasupplicant

linux_wpa_supplicant_config:
  file.managed:
    - name: /etc/wpa_supplicant/wpa_supplicant.conf
    - source: salt://linux/files/wpa_supplicant.conf
    - user: root
    - mode: 644
    - template: jinja
    - defaults:
        pillar: {{ pillar }}
    - require:
        - linux_system_wifi_packages

linux_wpa_supplicant_service:
  service.running:
    - name: wpa_supplicant
    - enable: true
    - watch:
        - linux_wpa_supplicant_config

{% endif %}

{% endif %}

{% if 'timezone' in pillar.linux %}
linux_system_timezone:
  timezone.system:
    - name: '{{ pillar.linux.timezone }}'
    - utc: true
{% endif %}

{% for host in pillar.linux.hosts %}
linux_network_host_{{ host.address }}:
  host.present:
    - ip: '{{ host.address }}'
    - names: {{ host.names }}
{% endfor %}

{% for param in pillar.linux.kernel.parameters %}
linux_system_kernel_param_{{ param.name }}:
  sysctl.present:
    - name: {{ param.name }}
    - value: {{ param.value }}
{% endfor %}

{% for package in pillar.linux.packages %}
linux_system_package_{{ package.name }}:
{% if 'purged' in package %}
  pkg.purged:
    - name: {{ package.name }}
{% else %}
{% if 'version' in package %}
{% if package.version == 'latest' %}
  pkg.latest:
    - name: {{ package.name }}
    - require:
        {% for repo in pillar.linux.repositories %}
        - linux_system_repository_{{ repo.name }}
        {% endfor %}
{% else %}
  pkg.installed:
    - name: {{ package.name }}
    - version: {{ param.version }}
    - require:
        {% for repo in pillar.linux.repositories %}
        - linux_system_repository_{{ repo.name }}
        {% endfor %}
{% endif %}
{% else %}
  pkg.installed:
    - name: {{ package.name }}
    - require:
        {% for repo in pillar.linux.repositories %}
        - linux_system_repository_{{ repo.name }}
        {% endfor %}
{% endif %}
{% endif %}
{% endfor %}

{% for repo in pillar.linux.repositories %}
linux_system_repository_{{ repo.name }}:
  pkgrepo.managed:
    - refresh_db: true
    - file: '/etc/apt/sources.list.d/{{ repo.name }}.list'
    - clean_file: true
    {% if 'ppa' in repo %}
    - ppa: {{ repo.ppa }}
    {% else %}
    - humanname: {{ repo.name }}
    - name: {{ repo.source }}
    {% endif %}
    {% if 'architectures' in repo %}- architectures: {{ repo.architectures }}{% endif %}
    {% if 'key_id' in repo %}- keyid: '{{ repo.key_id }}'{% endif %}
    {% if 'key_server' in repo %}- keyserver: '{{ repo.key_server }}'{% endif %}
    {% if 'key_url' in repo %}- key_url: '{{ repo.key_url }}'{% endif %}
{% endfor %}

{% for file in pillar.linux.files %}
linux_system_file_{{ file.name }}:
{% if 'marker_start' in file %}
  file.blockreplace:
    - name: {{ file.name }}
    - content: {{ file.content }}
    - marker_start: {{ file.marker_start }}
    - marker_end: {{ file.marker_end }}
    {% if 'append_if_not_found' in file %}
    - append_if_not_found: '{{ file.append_if_not_found }}'
    {% endif %}
    {% if 'prepend_if_not_found' in file %}
    - prepend_if_not_found: '{{ file.prepend_if_not_found }}'
    {% endif %}
    {% if 'append_newline' in file %}
    - append_newline: '{{ file.append_newline }}'
    {% endif %}
{% else %}
  file.managed:
    - name: {{ file.name }}
    - makedirs: true
    {%- if 'content' in file %}
    - contents: {{ file.content }}
    {%- endif %}
    {%- if 'source' in file %}
    - source: {{ file.source }}
    {%- endif %}
    {% if 'user' in file %}- user: '{{ file.user }}'{% endif %}
    {% if 'group' in file %}- group: '{{ file.group }}'{% endif %}
{% endif %}
{% endfor %}

{% for dir in pillar.linux.directories %}
linux_dir_{{ dir.name }}:
  file.directory:
    - name: '{{ dir.name }}'
    - makedirs: true
    {% if 'user' in dir %}- user: '{{ dir.user }}'{% endif %}
    {% if 'group' in dir %}- group: '{{ dir.group }}'{% endif %}
    {% if 'dir_mode' in dir %}- dir_mode: '{{ dir.dir_mode }}'{% endif %}
    {% if 'file_mode' in dir %}- file_mode: '{{ dir.file_mode }}'{% endif %}
{% endfor %}

{% for mount in pillar.linux.mounts %}
linux_mount_{{ mount.mount }}:
  mount.mounted:
    - device: {{ mount.device }}
    - fstype: {{ mount.file_system }}
    {% if 'options' in mount %}- opts: '{{ mount.options }}'{% endif %}
    {% if 'mkmnt' in mount %}- mkmnt: '{{ mount.mkmnt }}'{% endif %}
{% endfor %}

{% if grains.os == 'Ubuntu' and grains.osrelease|float > 18 %}
#linux_network_interfaces_clean:
#  file.directory:
#    - name: /etc/netplan
#    - clean: true
#    - require:
#        {% for iface in pillar.linux.interfaces %}
#        - linux_network_interface_{{ iface.name }}
#        {% endfor %}
{% else %}
linux_network_interfaces_clean:
  file.directory:
    - name: /etc/network/interfaces.d
    - clean: true
{% endif %}

{% for iface in pillar.linux.interfaces %}
linux_network_interface_{{ iface.name }}: 
  file.managed:
    {% if grains.os == 'Ubuntu' and grains.osrelease|float > 18 %}
    - name: /etc/netplan/00-salt-config.yaml
    - source: salt://linux/files/netplan.yml
    {% else %}
    - name: /etc/network/interfaces
    - source: salt://linux/files/ifupdown
    {% endif %}
    - user: root
    - mode: 644
    - template: jinja
    - defaults:
        pillar: {{ pillar }}
{% endfor %}

{% for user in pillar.linux.users %}
{% if user.get('absent', false) %}

linux_system_user_{{ user.name }}:
  user.absent:
    - name: {{ user.name }}

{% else %}

linux_system_user_{{ user.name }}:
  user.present:
    - name: {{ user.name }}
    - home: {% if 'home' in user %}{{ user.home }}{% else %}/home/{{ user.name }}{% endif %}
    - shell:  {% if 'shell' in user %}{{ user.shell }}{% else %}/bin/bash{% endif %}
    {% if 'system' in user %}- system: {{ user.system }}{% endif %}
    {% if 'password' in user %}- password: {{ user.password }}{% endif %}
    {% if 'hash_password' in user %}- hash_password: {{ user.hash_password }}{% endif %}
    {% if 'enforce_password' in user %}- enforce_password: {{ user.enforce_password }}{% endif %}
    {% if 'unique' in user %}- unique: {{ user.unique }}{% endif %}
    {% if 'uid' in user %}- uid: {{ user.uid }}{% endif %}
    {% if 'gid' in user %}- gid: {{ user.gid }}{% endif %}

linux_system_user_{{ user.name }}_home:
  file.directory:
    - name: /home/{{ user.name }}
    - user: {{ user.name }}
    - makedirs: true
    - require:
        - 'linux_system_user_{{ user.name }}'

linux_system_user_{{ user.name }}_sudo:
  file.managed:
    - name: '/etc/sudoers.d/90-salt-user-{{ user.name }}'
    - user: 'root'
    - group: 'root'
    - mode: 440
    - contents: '{{ user.name }} ALL=(ALL) NOPASSWD:ALL'
    - check_cmd: '/usr/sbin/visudo -c -f'
    - require:
        - 'linux_system_user_{{ user.name }}'

{% for key in user.ssh_keys %}
linux_system_user_{{ user.name }}_key_{{ loop.index }}:
  ssh_auth.present:
    - user: {{ user.name }}
    - name: {{ key }}
    - require:
        - 'linux_system_user_{{ user.name }}'
{% endfor %}

{% endif %}
{% endfor %}

{% for proxy in pillar.linux.proxies %}
{% if proxy.kind == 'napalm' %}

linux_proxy_napalm_packages:
  pkg.installed:
    - names:
        - python-dev
        - python-pip
        - libssl-dev
        - libffi-dev
        - libxslt1-dev
        - python-cffi

linux_proxy_napalm_libraries:
  pkg.installed:
    - pkgs:
        - napalm==2.5.0
        - napalm-ros==0.8.0
        - https://github.com/barneysowood/napalm-edgeos/archive/develop.zip
    - require:
        - linux_proxy_napalm_packages

{% endif %}
{% endfor %}

{% endif %}

{% endif %}
