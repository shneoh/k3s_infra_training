#!/bin/bash

# Install etcdctl (etcd client)
set -e

ETCD_VERSION="v3.5.5"
ETCD_URL="https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz"

# Check if etcdctl is already installed
if command -v etcdctl >/dev/null 2>&1; then
  echo "[INFO] etcdctl is already installed at: $(which etcdctl)"
  echo "[INFO] Skipping installation."
  exit 0
fi

echo "[INFO] Downloading and installing etcdctl ${ETCD_VERSION}..."
sudo curl -sL ${ETCD_URL} | sudo tar -zxv --strip-components=1 -C /usr/local/bin

echo "[INFO] etcdctl installed successfully."