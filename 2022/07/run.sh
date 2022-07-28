#!/bin/sh

install_package() {
  PACKAGE_NAME="${1}"

  if ! apt list -i "${PACKAGE_NAME}" | grep -q "${PACKAGE_NAME}" 2> /dev/null; then
      sudo apt install -y "${PACKAGE_NAME}"
  fi
}

set -eux

if [ ! -d ./.venv ]; then
  virtualenv ./.venv
fi

install_package libx11-dev
install_package libxext-dev

. ./.venv/bin/activate

pip install lookatme

pip install lookatme.contrib.image_ueberzug

lookatme --live --debug ./cloud_native_homelab.md
