docker:
  runtime: default
  registries: []
  insecure_registries: []
{% if grains.os_family == 'Debian' %}
{% if grains.os == 'Ubuntu' %}
  {% set os = grains.os|lower %}
{% else %}
  {% set os = grains.os_family|lower %}
{% endif %}
linux:
  packages:
    {% if grains.osarch == 'amd64' %}
    - name: binfmt-support
    {% endif %}
    - name: docker-ce
    - name: docker-ce-cli
  repositories:
    - name: docker
      source: deb [arch={{ grains.osarch }}] https://download.docker.com/linux/{{ os }} {{ grains.oscodename }} stable
      key_url: https://download.docker.com/linux/ubuntu/gpg
{% endif %}
