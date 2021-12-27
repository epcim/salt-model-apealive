# states

apealive:
  '*': []

  #'pc-*|ntbk-*|dontpanic':

  'cmp*|compute*':
    - users
    - packages
    - salt
    - linux
    - microk8s
    - node_exporter

  '*-nuc*': []

  '*-rpi*':
    - linux
    - raspberrypi
 
  #'G@os:Ubuntu':
  #'G@os:MacOS':
  #  - pkgs.dev.{{ grains.id }}

