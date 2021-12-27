
# Doc: https://github.com/saltstack-formulas/packages-formula/blob/master/pillar.example

packages:
  pkgs:
    wanted:
      - apt-transport-https
      - ca-certificates
      - curl
      - open-iscsi
  pips:
    wanted: {}
  snaps:
    wanted:
      - microk8s
  gems:
    wanted: {}
  archives: 
    wanted: {}
 
