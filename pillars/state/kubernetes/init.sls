kubernetes:
  version: unknown
  role: node
  deploy:
    kind: kubeadm
  api:
    host: unknown
    port: 6443
linux:
  swap:
    kind: none
  {% if grains.os_family == 'Debian' %}
  files:
  - name: /usr/share/keyrings/kubernetes-archive-keyring.gpg
    source: salt://_keyrings/kubernetes-archive-keyring.gpg
  repositories:
    - name: kubernetes
      source: deb [arch={{ grains.osarch }} signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] http://apt.kubernetes.io/ kubernetes-xenial main
  {% endif %}
  kernel:
    parameters:
      - name: net.ipv4.ip_forward
        value: 1
