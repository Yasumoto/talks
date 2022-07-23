#!/bin/sh

set -eux

virtualenv ./.venv

. ./.venv/bin/activate

pip install lookatme

pip install lookatme.contrib.image_ueberzug
