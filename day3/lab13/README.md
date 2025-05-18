# Lab 13: Vertical Pod Autoscaler (VPA)

## 🎯 Objective

This lab demonstrates how to use Vertical Pod Autoscaler (VPA) in Kubernetes to automatically adjust CPU and memory resource requests for pods based on observed usage.

Students will:

* Install the VPA components
* Deploy a sample container workload
* Observe VPA recommendations
* Optionally test automated updates using `Auto` mode

> ⚠️ This lab is designed for **k3s** and assumes you have a working cluster ready.

---

## 🛠️ Tasks Overview

1. Install the VPA components (Recommender, Updater, Admission Controller)
2. Deploy a sample workload
3. Apply a VPA object in `recommendation` mode
4. Observe recommended resource requests
5. Switch to `Auto` mode and validate updates

---

## 🔧 Setup Instructions

### ✅ 1. Create Namespace

```bash
kubectl create namespace vpa-lab
```

### ✅ 2. Install VPA Components

```bash
 ./manifest/hack/vpa-up.sh
```

### ✅ 3. Deploy Sample Workload

```bash
kubectl apply -f manifest/sample-deployment.yaml
```

### ✅ 4. Apply VPA in Recommender Mode

```bash
kubectl apply -f manifest/vpa-recommendation.yaml
```

### ✅ 5. Monitor VPA Recommendations

```bash
kubectl describe vpa sample-app -n vpa-lab
```

Look for lines like:

```
Recommendation:
  Container Recommendations:
    Container Name:  app
    Lower Bound:
      cpu:     20m
      memory:  50Mi
    Target:
      cpu:     50m
      memory:  150Mi
    Upper Bound:
      cpu:     100m
      memory:  250Mi
```

---

## 🔁 Optional: Test Auto Mode

### ✅ 1. Apply VPA with Auto Update

```bash
kubectl apply -f manifest/vpa-auto.yaml
```

### ✅ 2. Observe Pod Restart and Updates

```bash
kubectl get pods -n vpa-lab
```

```bash
kubectl describe pod <pod-name> -n vpa-lab
```

You should see updated resource `requests` inline with VPA target recommendations.

---

## 🧼 Cleanup (Optional)

```bash
kubectl delete ns vpa-lab
```

---

## ✅ Validation Checklist

* VPA components installed successfully
* Sample deployment running
* VPA recommendation visible
* Resource requests updated (if Auto mode used)
