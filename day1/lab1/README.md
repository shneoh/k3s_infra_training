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
    curl -sfL https://get.k3s.io | K3S_TOKEN="SECRET" sh -s - server \
    --cluster-init \
    --tls-san kubeapi.stuXX.steven.asia \
    --tls-san vmk3s001-stuXX \
    --tls-san 10.0.0.5 \
    --node-name vmk3s001-stuXX \
    --write-kubeconfig-mode 644 \
    --etcd-expose-metrics \
    --kube-controller-manager-arg bind-address=0.0.0.0 \
    --kube-scheduler-arg bind-address=0.0.0.0 \
    --kube-proxy-arg metrics-bind-address=0.0.0.0:10249

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
    --write-kubeconfig-mode 644 \
    --kube-controller-manager-arg bind-address=0.0.0.0 \
    --kube-scheduler-arg bind-address=0.0.0.0 \
    --kube-proxy-arg metrics-bind-address=0.0.0.0:10249

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
    --write-kubeconfig-mode 644 \
    --kube-controller-manager-arg bind-address=0.0.0.0 \
    --kube-scheduler-arg bind-address=0.0.0.0 \
    --kube-proxy-arg metrics-bind-address=0.0.0.0:10249

  ```
> ⚠️ Replace `stuXX` with your actual student number (e.g., `stu01`, `stu02`, etc.)

---

## ✅ Validation

After installing on all three nodes:
  ```bash
    kubectl get nodes -o wide
  ```

You should see all 3 nodes in `Ready` state and all control-plane components running.
>> enable kubectl auto completion 

```sh 
echo 'source <(kubectl completion bash)' >> ~/.bashrc
source ~/.bashrc
```


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


## 🔎 Verifying K3s Embedded CNI (Flannel), CoreDNS, and Traefik

### ✅ 1. Check if Flannel Interface Exists (CNI verification)

```bash
ip a | grep flannel
```

You should see an interface like `flannel.1`, confirming that the Flannel overlay network is active on the node.

---

### ✅ 2. Check K3s Logs for Flannel Activity

```bash
sudo journalctl -u k3s | grep flannel
```

Look for logs showing Flannel subnet assignments and initialization.

---

### ✅ 3. Check CNI Plugin Configuration

```bash
cat /etc/cni/net.d/10-flannel.conflist
```

Confirms that Flannel is installed and configured as the default CNI plugin.

---

## 🧪 Verify Default K3s System Components

### ✅ 4. List All Pods in `kube-system` Namespace

```bash
kubectl get pods -n kube-system -o wide
```

Look for:

* `coredns-*` → Kubernetes DNS
* `traefik-*` → Ingress controller
* `metrics-server-*` → Optional metrics service
* `svclb-traefik-*` → LoadBalancer sidecar pods per node

---

### ✅ 5. Check CoreDNS Deployment Details

```bash
kubectl describe deployment coredns -n kube-system
```

This shows number of replicas, image used, and events such as health or restart behavior.

---

### ✅ 6. Verify CoreDNS Service Exposure

```bash
kubectl get svc -n kube-system
```

You should see:

* `kube-dns` (a `ClusterIP` service) — backing CoreDNS.

---

### ✅ 7. Confirm Traefik is Running

```bash
kubectl get deploy -n kube-system | grep traefik
```

And check its service:

```bash
kubectl get svc -n kube-system | grep traefik
```

```bash 
kubectl -n kube-system patch deployment traefik -p '{"spec": {"replicas": 3}}'
```
>> Since we have 3 node, we want to ensure, traefik ingress runs on all 3 node

This should show a `LoadBalancer` or `ClusterIP` type service exposing the Ingress controller.

---

### ✅ 8. Install kube-state-metrics

* By Default any Kubernetes deployment will not have kube-state-metrics, you can install an instance to 
gather kubernetes core metrics ( used in later modules )

  >> In k3s, metric-server is installed by default, but it will only provide telemetry of nodes and pods 

```bash 
git clone https://github.com/stv707/k3s_infra_training.git
```
```sh 
cd k3s_infra_training/day1/lab1
```

```sh 
kubectl apply -f kube-state-metrics/. 
```

* Verify kube-state-metrics is up and running 
```sh 
kubectl get deployments.apps -n kube-system
```

```sh 
kubectl get pod -n kube-system -l app.kubernetes.io/name=kube-state-metrics
```



### ✅ 9. Install longhorn Distributed CSI

* By Default any k3s uses local-path as a default storage (csi ) Provider

  >> In k3s you can install longhorn to support true HA 

```bash 
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.8.1/deploy/longhorn.yaml
```
```sh 
kubectl patch storageclass local-path -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "false"}}}'
```

```sh 
kubectl get sc
```

* Verify kube-state-metrics is up and running 
```sh 
kubectl get all -n longhorn-system
```

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