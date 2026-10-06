#!/usr/bin/env bash
set -euo pipefail

# Copy and install any root CA certificates required on certain machines
# (mount a local directory containing certificates in *.pem format at `/mnt/ca-root-certs`)
if [ -d /mnt/ca-root-certs ]; then
    sudo cp /mnt/ca-root-certs/*.pem /etc/pki/ca-trust/source/anchors/
    sudo update-ca-trust
fi

# Set ready marker
sudo touch /run/ready

exec "$@"
