# Lab 02: etcd Snapshot and Recovery

## 🎯 Objective

This lab demonstrates how to:

* Deploy a sample application (Vote App)
* Install and use `etcdctl` to inspect the embedded etcd cluster
* Take a snapshot of etcd data
* Simulate etcd failure
* Recover the cluster using the saved snapshot

---

## 🛠️ Lab Setup

### ✅ Step 1: Clone the Training Repository

Students must clone the training repository and navigate to Lab 02:

```bash
git clone https://github.com/stv707/k3s_infra_training.git
cd k3s_infra_training/day1/lab2
```

### ✅ Step 2: Deploy the Vote App

Ensure your cluster is running, then apply the app manifest
>> Before applying the manifest file, update the manifest with your Student Number XX 

```bash 
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: voteapp-ingress
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web
spec:
  rules:
  - host: voteapp.app.stuXX.steven.asia # CHANGE THE XX to your student number
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: voteapp-frontend
            port:
              number: 80

```

```bash
kubectl apply -f voteapp.yaml
```

### ✅ Step 3: Confirm App Deployment

```bash
kubectl get pods -o wide
kubectl get svc
kubectl get ingress
```

Look for `voteapp-frontend` as a LoadBalancer service and all pods in Running state.

```bash 
kubectl get ingress voteapp-ingress -o jsonpath="{.spec.rules[0].host}" | xargs -I{} echo "http://{}"
```
Get the address and access it via your browser 

---

## 🔧 etcdctl Installation

To simplify the process, we’ve provided a script to install the `etcdctl` binary for you.

### ✅ Step 1: On the first control-plane node (vmk3s001-stuXX)

Navigate to the lab folder and run the install script:

```bash
cd k3s_infra_training/day1/lab2
bash install_etcd.sh
```

This script will:

* Download `etcdctl v3.5.5` from the official GitHub release
* Extract it and move the binary to `/usr/local/bin`
* Make it ready for use cluster-wide

Once complete, proceed to the etcd inspection steps.

---

## 🔍 Inspect etcd Cluster

Before snapshotting, explore the cluster:

### ✅ Set Environment Variables

```bash
export ETCDCTL_API=3
export ENDPOINTS=https://127.0.0.1:2379
export CACERT="/var/lib/rancher/k3s/server/tls/etcd/server-ca.crt"
export CERT="/var/lib/rancher/k3s/server/tls/etcd/client.crt"
export KEY="/var/lib/rancher/k3s/server/tls/etcd/client.key"
```

### ✅ Run etcdctl Checks

```bash
sudo etcdctl --endpoints=$ENDPOINTS \
  --cacert=$CACERT \
  --cert=$CERT \
  --key=$KEY member list --write-out=table
```

```bash 
sudo etcdctl --endpoints=$ENDPOINTS \
  --cacert=$CACERT \
  --cert=$CERT \
  --key=$KEY endpoint health --cluster --write-out=table
```

```bash 
sudo etcdctl --endpoints=$ENDPOINTS \
  --cacert=$CACERT \
  --cert=$CERT \
  --key=$KEY endpoint status --cluster --write-out=table
```

These commands help identify etcd members, leader, and overall cluster health.

---

## 💾 Take an etcd Snapshot

```bash
sudo k3s etcd-snapshot save --name pre-failure-snapshot
```

```bash 
sudo k3s etcd-snapshot ls
```

Snapshots are stored under:

```bash
sudo ls -l /var/lib/rancher/k3s/server/db/snapshots/
```

---

## 💣 Simulate etcd Failure

### ✅ On your primary control-plane node:

```bash
sudo systemctl stop k3s
```

```bash 
sudo rm -rf /var/lib/rancher/k3s/server/db/etcd
```

Attempting any `kubectl` commands now will result in failure.


```bash 
kubectl get pods 
```

Attempting to start k3s server service will result in failure.


```bash 
sudo systemctl start k3s
```


---

## 🔁 Restore from Snapshot

### ✅ Run stop k3s on (node2 and node3) and remove db dir :

```bash
sudo systemctl stop k3s 
sudo rm -rf /var/lib/rancher/k3s/server/db/
```

Then on node1 run the following:

```bash
sudo bash -c "ls -l /var/lib/rancher/k3s/server/db/snapshots/pre-*"
```

Copy the path from above and run 
```bash
sudo  k3s server \
  --cluster-reset \
  --cluster-reset-restore-path=<PATH> 
```
>> You should see : Managed etcd cluster membership has been reset, restart without --cluster-reset flag now.

```bash
sudo systemctl start k3s 
```

* On node2 and node3 start the k3s 
```bash
sudo systemctl start k3s 
```

### ✅ Revalidate:

```bash
kubectl get pods -A
kubectl get svc
kubectl get nodes
```

Ensure the Vote App has returned and control plane is functional.

---

## 📌 Key Takeaway

This lab showed:

* How to inspect etcd cluster health using etcdctl
* How to take and list snapshots
* How to simulate failure and successfully recover a K3s control plane using a snapshot
