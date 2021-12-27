wireguard: {}
{% if grains.os == 'Ubuntu' and grains.oscodename in ['xenial', 'bionic'] %}
linux:
  repositories:
    - name: wireguard
      source: deb http://ppa.launchpad.net/wireguard/wireguard/ubuntu {{ grains.oscodename }} main
      key_server: hkp://keyserver.ubuntu.com:80
      key_id: AE33835F504A1A25
{% endif %}
