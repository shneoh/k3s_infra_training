# Lab 11: Kubernetes RBAC Deep Dive
## 🎯 Objective

This lab demonstrates practical, real-world applications of Kubernetes RBAC based on the concepts introduced in lesson. We will:

* Create roles and bind them to service accounts
* Attempt actions as those service accounts
* Understand the difference between Role and ClusterRole in action
* Practice isolating permissions across namespaces

## 🛠️ Tasks Overview

* Practice 1: Namespaced Role & RoleBinding
* Practice 2: ClusterRole for Cluster-Wide Access
* Practice 3: Unauthorized Access Attempt + Minimal `kubectl auth can-i`

Each task will be followed by real command validation using pods running the `curlimage` image.

---

## 🔧 Setup Instructions

### ✅ 1. Create Lab Namespace

```bash
kubectl create ns rbac-lab
```

### ✅ 2. Create Service Account for Practice

```bash
kubectl create serviceaccount viewer -n rbac-lab
```

### ✅ 3. Deploy Demo Pod as a ServiceAccount

```bash
kubectl apply -f manifest/viewer-pod.yaml
```

### ✅ 4. Apply Role

```bash
kubectl apply -f manifest/role-pod-reader.yaml
```

### ✅ 5. Apply RoleBinding

```bash
kubectl apply -f manifest/rolebinding-pod-reader.yaml
```

### ✅ 6. Validate Allowed Action (list pods)

```bash
kubectl exec -n rbac-lab viewer-pod -- kubectl get pods -n rbac-lab
```

### ✅ 7. Try Unauthorized Action (create secret)

```bash
kubectl exec -n rbac-lab viewer-pod -- kubectl create secret generic mysecret --from-literal=foo=bar -n rbac-lab
```

---

## ✨ Practice 2: ClusterRole & ClusterRoleBinding

### ✅ 1. Apply ClusterRole

```bash
kubectl apply -f manifest/clusterrole-pod-reader.yaml
```

### ✅ 2. Apply ClusterRoleBinding

```bash
kubectl apply -f manifest/clusterrolebinding-pod-reader.yaml
```

### ✅ 3. Create New Namespace

```bash
kubectl create ns devspace
```

### ✅ 4. Create Service Account in New Namespace

```bash
kubectl create serviceaccount inspector -n devspace
```

### ✅ 5. Deploy Pod with ServiceAccount

```bash
kubectl apply -f manifest/inspector-pod.yaml
```

### ✅ 6. Test Cluster-Level Pod Access

```bash
kubectl exec -n devspace inspector-pod -- kubectl get pods -A
```

---

## ❌ Practice 3: Unauthorized Attempt (Minimal `kubectl auth can-i`)

### ✅ 1. Check a denied action

```bash
kubectl auth can-i delete deployments --as=system:serviceaccount:rbac-lab:viewer -n rbac-lab
```

Expected output:

```
no
```

---

## ✅ Validation

* Able to list pods as `viewer` and `inspector`
* Forbidden on sensitive operations without Role/Binding
* ClusterRoleBinding applies cross-namespace

---

## 🔥 Cleanup (Optional)

```bash
kubectl delete ns rbac-lab
```

```bash
kubectl delete ns devspace
```

---