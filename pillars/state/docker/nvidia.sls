# https://nvidia.github.io/libnvidia-container/
linux:
  packages:
    - name: gcc
    - name: make
    - name: nvidia-docker2
  repositories:
    - name: libnvidia-container
      source: deb [arch={{ grains.osarch }}] https://nvidia.github.io/libnvidia-container/stable/ubuntu18.04/{{ grains.osarch }} /
      key_url: https://nvidia.github.io/nvidia-docker/gpgkey
    - name: nvidia-container-runtime
      source: deb [arch={{ grains.osarch }}] https://nvidia.github.io/nvidia-container-runtime/stable/ubuntu18.04/{{ grains.osarch }} /
      key_url: https://nvidia.github.io/nvidia-docker/gpgkey
    - name: nvidia-docker
      source: deb [arch={{ grains.osarch }}] https://nvidia.github.io/nvidia-docker/ubuntu18.04/{{ grains.osarch }} /
      key_url: https://nvidia.github.io/nvidia-docker/gpgkey
docker:
  runtime: nvidia