#!/bin/bash

# Install etcdctl (etcd client)
set -e

ETCD_VERSION="v3.5.5"
ETCD_URL="https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz"

echo "[INFO] Downloading and installing etcdctl ${ETCD_VERSION}..."
sudo curl -sL ${ETCD_URL} | sudo tar -zxv --strip-components=1 -C /usr/local/bin

echo "[INFO] etcdctl installed successfully."
