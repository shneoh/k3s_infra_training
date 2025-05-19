# Lab 14: Pod Design Patterns – Init & Sidecar Containers

## 🎯 Objective

This lab introduces two fundamental Pod design patterns in Kubernetes:

* Init Containers: used for setup tasks before the main container runs
* Sidecar Containers: run alongside the main container to extend functionality

Students will:

* Deploy a Pod with an Init Container that simulates setup work
* Deploy a Pod with a Sidecar Container that performs simple background logging

---

## 🛠️ Tasks Overview

1. Deploy a Pod with an Init Container
2. Observe its sequential lifecycle
3. Deploy a Pod with a Sidecar Container
4. Observe how both containers run in parallel

---

## 🔧 Setup Instructions

### ✅ 1. Create Namespace

```bash
kubectl create namespace pod-patterns
```

### ✅ 2. Apply Init Container Deployment

```bash
kubectl apply -f manifest/init-container-demo.yaml
```

### ✅ 3. Observe Pod Lifecycle

```bash
kubectl get pods -n pod-patterns -w
```



```bash
kubectl describe pod <init-pod-name> -n pod-patterns
```

Look for the Init container phase completing before the main container starts.

---

### ✅ 4. Apply Sidecar Deployment

```bash
kubectl apply -f manifest/sidecar-container-demo.yaml
```

### ✅ 5. Observe Sidecar Behavior

```bash
kubectl logs -f <sidecar-pod-name> -c sidecar -n pod-patterns
```

```bash
kubectl logs -f <sidecar-pod-name> -c main -n pod-patterns
```

Both logs should stream in parallel, showing side-by-side functionality.

---

## 🧼 Cleanup (Optional)

```bash
kubectl delete ns pod-patterns
```

---

## ✅ Validation Checklist

* Init container completes before the main app starts
* Sidecar and main container run in parallel
* Logs confirm distinct container responsibilities within a single Pod
