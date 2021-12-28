# states

apealive:
  #'*': []

  #'pc-* or ntbk-* or dontpanic':

  'cmp* or compute*':
    - users
    - packages
    - salt
    - linux
    - microk8s
    - node_exporter

  #'*-nuc*': []

  '*-rpi*':
    - linux
    - raspberrypi
 
  #'G@os:Ubuntu':
  #'G@os:MacOS':
  #  - pkgs.dev.{{ grains.id }}

