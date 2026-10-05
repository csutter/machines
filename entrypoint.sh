#!/usr/bin/env bash
set -euo pipefail

sudo touch /run/ready
exec sleep infinity
