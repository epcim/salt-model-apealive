# pilars

apealive:

  '*':
    - node.{{ grains.id }}
    # ^^ non-defined minions will fail to apply
    - defaults
    - state.users
    - state.packages

  '*-cmp*':
    - state.users.salt
    - state.packages.kubernetes
    - state.packages.microk8s

  '*-nuc*':
    - linux

  '*-rpi*': []

  'G@kernel:Linux': []
  'G@kernel:Windows': []
  'G@kernel:Darwin': []
    
# Examples:
#  'os:Ubuntu':
#    - match: grain
#    - linux.system.repo3
#  '^found*':
#    - match: pcreem.
#    - linux.system.repo
#  'f* and J@role.linux.system':
#    - match: compound
#    - users2
#  '192.0.0.0/16':
#    - match: ipcidr
#    - users
#  'G@os:Ubuntu':
#    - users.salt
#  'G@os:MacOS':
#    - users.salt

