
#include:
  #- xyz
  #- xyz.{{ grains.os | lower }}
  #

packages:
  pkgs:
    wanted:
      - fish
      - homeshick
      - kitty
      - starship
      - fzf

salt:
  id: dontpanic
linux:
  hostname: dontpanic

