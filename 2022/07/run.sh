#!/bin/sh

set -eux

if [ ! -d ./.venv ]; then
  virtualenv ./.venv
fi

. ./.venv/bin/activate

pip install lookatme

pip install lookatme.contrib.image_ueberzug

lookatme --live --debug ./cloud_native_homelab.md
