# Lab 12: Horizontal Pod Autoscaler (HPA)

## 🎯 Objective

This lab is about  how to implement Horizontal Pod Autoscaling (HPA) in Kubernetes using a CPU-based scaling trigger. In this exercise, you will:

* Deploy a sample PHP-Apache application
* Create a LoadGenerator to simulate traffic
* Configure and observe HPA behavior based on CPU usage

> ⚠️ This lab is adapted for **k3s**. The cluster is assumed to be fully operational with `metrics-server` installed.

---

## 🛠️ Tasks Overview

1. Deploy the PHP-Apache backend application
2. Create a Kubernetes HPA object
3. Deploy the LoadGenerator to simulate load
4. Observe autoscaling behavior
5. Scale down and clean up

---

## 🔧 Setup Instructions

### ✅ 1. Create Namespace

```bash
kubectl create namespace hpa-lab
```

### ✅ 2. Deploy the PHP-Apache App

```bash
kubectl apply -f manifest/php-apache.yaml
```

### ✅ 3. Confirm Deployment

```bash
kubectl get pods -n hpa-lab
```

### ✅ 4. Create the HPA Resource

```bash
kubectl apply -f manifest/hpa.yaml
```

### ✅ 5. Confirm HPA Object

```bash
kubectl get hpa -n hpa-lab
```

---

## 🚀 Load Simulation

### ✅ 1. Deploy the Load Generator

```bash
kubectl apply -f manifest/load-generator.yaml
```

### ✅ 2. Monitor HPA Activity

```bash
kubectl get hpa -n hpa-lab -w
```

>> You should see the replica count increase after a minute or two based on the CPU target threshold.

## 🚀 Manual Scale

### ✅ 1. Scale the deployment

```bash
kubectl get deployments.apps -n hpa-lab
```

```bash
kubectl scale --replicas=10 deployment -n hpa-lab php-apache
```

```bash
kubectl get deployments.apps -n hpa-lab
```

### ✅ 2. Check HPA 

```bash
kubectl get hpa -n hpa-lab
```

---

## 🧼 Cleanup (Optional)

```bash
kubectl delete namespace hpa-lab
```

---

## ✅ Validation Checklist

* HPA created with CPU-based scaling trigger
* Load Generator successfully increases CPU load
* Replica count increases in response
* App scales down when load is removed

