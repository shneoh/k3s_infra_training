# Lab 01: K3s HA Control Plane Setup

## 🎯 Objective

Deploy a multi-master High Availability (HA) K3s cluster using embedded etcd across three nodes:  
- `vmk3s001-stuXX` (Primary)
- `vmk3s002-stuXX` (Secondary)
- `vmk3s003-stuXX` (Secondary)

## 🛠️ Tasks

1. **Initialize K3s on the Primary Node (vmk3s001)**
2. **Join Secondary Nodes using the shared token**
3. **Verify etcd and control plane status**
4. **Test kubectl access and node roles**

## 💻 Commands Overview

### 🎯 Objective

Deploy a 3-node High Availability (HA) K3s cluster using embedded etcd with proper TLS SAN and external API access via:
[https://kubeapi.stuXX.steven.asia:6443](https://kubeapi.stuXX.steven.asia:6443)


## 🔧 Setup Instructions

1. **On terminal 1 , SSH into JumpHost and ssh to `vmk3s001-stuXX`:**

    ```bash
    ssh droot@ssh.stuXX.steven.asia

    ssh vmk3s001-stuXX
    ````

2. **Run the following on `vmk3s001-stuXX` (the first/master node):**

    ```bash
    curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET sh -s - server \
    --cluster-init \
    --tls-san kubeapi.stuXX.steven.asia \
    --tls-san vmk3s001-stuXX \
    --tls-san 10.0.0.5 \
    --node-name vmk3s001-stuXX \
    --write-kubeconfig-mode 644
    ```

3. **On terminal 2 , access `vmk3s002-stuXX`:**

    ```bash
    ssh droot@ssh.stuXX.steven.asia

    ssh vmk3s002-stuXX
    ````

    ```bash
    curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET sh -s - server \
    --server https://kubeapi.stuXX.steven.asia:6443 \
    --tls-san kubeapi.stuXX.steven.asia \
    --tls-san vmk3s002-stuXX \
    --tls-san 10.0.0.6 \
    --node-name vmk3s002-stuXX \
    --write-kubeconfig-mode 644
    ```

4. **On terminal 3 , access `vmk3s003-stuXX`:**

    ```bash
    ssh droot@ssh.stuXX.steven.asia

    ssh vmk3s003-stuXX
    ````
    ```bash
    curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET sh -s - server \
    --server https://kubeapi.stuXX.steven.asia:6443 \
    --tls-san kubeapi.stuXX.steven.asia \
    --tls-san vmk3s003-stuXX \
    --tls-san 10.0.0.7 \
    --node-name vmk3s003-stuXX \
    --write-kubeconfig-mode 644
    ```

> ⚠️ Replace `stuXX` with your actual student number (e.g., `stu01`, `stu02`, etc.)

---

## ✅ Validation

After installing on all three nodes:
  ```bash
    kubectl get nodes -o wide
  ```

You should see all 3 nodes in `Ready` state and all control-plane components running.

---

## 🧹 Reset (Optional)

To uninstall K3s on any node:

   ```sh
    sudo /usr/local/bin/k3s-uninstall.sh
   ```

---



