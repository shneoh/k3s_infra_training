# Lab 10: Pod Security Admission (PSA) Enforcement Lab

## 🌟 Objective

Understand the purpose and enforcement of Kubernetes Pod Security Admission (PSA) by deploying pods with and without proper security context, observing how PSA blocks or allows pod creation based on namespace labels.

## 🛠️ Tasks

1. Create two namespaces: one unrestricted, one with `restricted` enforcement
2. Deploy an insecure pod (`stv707/kubia:v14`) in both namespaces
3. Observe enforcement failure in the restricted namespace
4. Patch pod to include compliant securityContext
5. Attempt privilege escalation and hostPath mounts to demonstrate blocking
6. Deploy a fully compliant pod and observe success in restricted environment

## 💻 Commands Overview

This lab uses the image `stv707/kubia:v14` for all pod deployments.

* Namespaces: `open-ns`, `secure-ns`
* PSA labels:

  * `secure-ns`: `enforce=restricted`
  * `open-ns`: `enforce=privileged`
* All pods deployed using manifest files located in this directory.

## 🔧 Setup Instructions

### ✅ 1. Create and label namespaces

```bash
kubectl create ns secure-ns
kubectl label ns secure-ns pod-security.kubernetes.io/enforce=restricted

kubectl create ns open-ns
kubectl label ns open-ns pod-security.kubernetes.io/enforce=privileged
```

### ✅ 2. Apply basic pod manifest in both namespaces

```bash
kubectl apply -f pod-unrestricted.yaml -n open-ns  # Should succeed
kubectl apply -f pod-unrestricted.yaml -n secure-ns  # Should fail
```

### ✅ 3. Apply a compliant pod manifest in secure-ns

```bash
kubectl apply -f pod-restricted-compliant.yaml -n secure-ns  # Should succeed
```

### ✅ 4. Test privilege escalation rejection

```bash
kubectl apply -f pod-priv-escalation.yaml -n secure-ns  # Should fail
```

Expected PSA Rejection:

```
allowPrivilegeEscalation != false (container "kubia" must set securityContext.allowPrivilegeEscalation=false)
```

### ✅ 5. Test hostPath volume rejection

```bash
kubectl apply -f pod-hostpath.yaml -n secure-ns  # Should fail
```

Expected PSA Rejection:

```
hostPath volumes are forbidden
```

## 📂 Sample Pod Manifest: `pod-unrestricted.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nonsecure-pod
spec:
  containers:
  - name: kubia
    image: stv707/kubia:v14
    ports:
    - containerPort: 8080
```

### 📂 Compliant Pod Manifest: `pod-restricted-compliant.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  containers:
  - name: kubia
    image: stv707/kubia:v14
    ports:
    - containerPort: 8080
    securityContext:
      runAsNonRoot: true
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
      readOnlyRootFilesystem: true
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
```

### 📂 Privilege Escalation Pod Manifest: `pod-priv-escalation.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: escalate-pod
spec:
  containers:
  - name: kubia
    image: stv707/kubia:v14
    ports:
    - containerPort: 8080
    securityContext:
      allowPrivilegeEscalation: true
```

### 📂 HostPath Mount Pod Manifest: `pod-hostpath.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-pod
spec:
  containers:
  - name: kubia
    image: stv707/kubia:v14
    volumeMounts:
    - mountPath: /host-data
      name: host-volume
  volumes:
  - name: host-volume
    hostPath:
      path: /etc
      type: Directory
```

## 📉 Validation

### ✅ Check pod creation status

```bash
kubectl get pods -n open-ns
kubectl get pods -n secure-ns
```

Expected:

* Pod is `Running` in `open-ns`
* Pod is `Rejected` in `secure-ns` with PSA error

## 🤕 Troubleshooting Failed Pod

Inspect event logs for denied pod in `secure-ns`:

```bash
kubectl describe pod <pod-name> -n secure-ns
```

Look for errors such as:

```
violates PodSecurity "restricted:latest": allowPrivilegeEscalation=true, hostPath volume detected
```

## 🧪 Fixing the Pod

Update or apply:

```yaml
securityContext:
  runAsNonRoot: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
  readOnlyRootFilesystem: true
```

Re-apply the corrected pod manifest:

```bash
kubectl apply -f pod-restricted-compliant.yaml -n secure-ns
```

## 🤖 Additional Scenarios (coming next)

* ❌ Attempting hostPath mounts in restricted namespace
* ❌ Attempting privileged escalation in restricted namespace
* ✅ Deploying fully compliant pod with full `securityContext`

## 🔐 Key Takeaway

PSA labels enforce critical pod security constraints. Without proper `securityContext`, pods will be rejected in hardened namespaces. Learning to create compliant manifests is essential for running workloads securely.

## 🧹 Reset (Optional)

```bash
kubectl delete ns secure-ns
kubectl delete ns open-ns
```
