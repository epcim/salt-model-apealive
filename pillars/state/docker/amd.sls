# https://rocmdocs.amd.com/en/latest/Installation_Guide/Installation-Guide.html
linux:
  repositories:
    - name: rocm
      source: deb [arch={{ grains.osarch }}] http://repo.radeon.com/rocm/apt/debian/ xenial main
      key_url: http://repo.radeon.com/rocm/rocm.gpg.key
  packages:
    - name: libnuma-dev
    - name: rocm-dkms
docker:
  runtime: amd