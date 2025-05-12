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
> ⚠️ Replace `stuXX` with your actual student number (e.g., `stu01`, `stu02`, etc.)
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
> ⚠️ Replace `stuXX` with your actual student number (e.g., `stu01`, `stu02`, etc.)
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




## 🧪 Verify the Power of the K3s Binary

In this section, you will confirm that **K3s runs as a single binary**, packaging all core Kubernetes components into one lightweight executable.

---

### ✅ 1. Check the Binary File

```bash
ls -lh /usr/local/bin/k3s
```

This should return a single file (\~75–100MB), confirming that K3s is shipped as one binary.

---

### ✅ 2. Inspect Running Processes

```bash
ps aux | grep k3s
```

You should see one `k3s` process spawning multiple subcomponents:

* `kube-apiserver`
* `controller-manager`
* `scheduler`
* `etcd`
* `containerd`
* `flannel`

All from a single binary, managed internally by K3s and subcomponent are in containers spawned by k3s binary.

---

### ✅ 3. Peek Inside the Binary (Optional)

Run this to see embedded component references:

```bash
strings /usr/local/bin/k3s | grep -E 'kube|etcd|flannel|containerd'
```

This confirms that K3s bundles everything in-process.


---

### ✅ 4. Verify Active K3s Systemd Service

Use the following to confirm that **only a single systemd service** is managing your entire K3s control plane:

```bash
systemctl status k3s
```

Expected output:

* Service name: `k3s`
* Description: `Lightweight Kubernetes`
* Active: `active (running)`
* Managed process: `/usr/local/bin/k3s server ...`

> 🔥 You won’t see `kubelet`, `kube-apiserver`, `etcd`, or `containerd` as separate services — K3s handles them internally.

---

### ✅ 5. Bonus: Check for other systemd units

To confirm no other core K8s services are running independently:

```bash
systemctl list-units --type=service | grep -E 'kube|etcd|containerd'
```
Expected result:  nothing else K8s-specific

---


### 📌 Key Takeaway

K3s simplifies the Kubernetes control plane by embedding all core services into a single binary — reducing system overhead, simplifying management, and making HA setups easier to deploy and maintain.

---


## 🧹 Reset (Optional)

To uninstall K3s on any node:

   ```sh
    sudo /usr/local/bin/k3s-uninstall.sh
   ```

---



