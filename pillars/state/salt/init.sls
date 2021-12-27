salt:
  id: node
  standalone: true
  master:
    publish_port: 4505
    master_port: 4506
{% if grains.os_family == 'Debian' %}
linux:
  files:
  - name: /usr/share/keyrings/salt-archive-keyring.gpg
    source: salt://_keyrings/salt-archive-keyring.gpg
  repositories:
    - name: saltstack
      {% if grains.os == 'Ubuntu' %}
        {% set release = grains.osrelease|string %}
        {% set os = grains.os|lower %}
      {% else %}
        {% set release = grains.osmajorrelease|string %}
        {% set os = grains.os_family|lower %}
      {% endif %}
      {% if grains.osarch == 'arm64' %}
        {% set osarch = 'armhf' %}
      {% else %}
        {% set osarch = grains.osarch %}
      {% endif %}
      {% set path = 'py3/' + os + '/' + release + '/' + osarch + '/archive/3003.3' %}
      source: deb [arch={{ osarch }} signed-by=/usr/share/keyrings/salt-archive-keyring.gpg] http://repo.saltstack.com/{{ path }} {{ grains.oscodename }} main
{% endif %}