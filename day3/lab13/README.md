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

### ✅ 1. Install VPA Components and verify 

* This script will download and install the VPA component
* The script is part of https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler

```bash
 git clone https://github.com/kubernetes/autoscaler.git
```

```bash
 cd autoscaler/vertical-pod-autoscaler/
```

```bash
 ./hack/vpa-up.sh
```


* Verify all vpa component is working

```bash 
kubectl get pod -n kube-system -l app=vpa-admission-controller
```

```bash 
kubectl get pod -n kube-system -l app=vpa-recommender
 ```

```bash 
kubectl get pod -n kube-system -l app=vpa-updater
```

### ✅ 2. Create Namespace
```bash
kubectl create namespace vpa-lab
```

### ✅ 3. Deploy Sample Workload
```bash
kubectl apply -f manifest/lab/sample-deployment.yaml
```

```sh 
kubectl get pod -n vpa-lab
```

```sh 
kubectl top pod -n vpa-lab
```

### ✅ 4. Apply VPA in Recommender Mode
```bash
kubectl apply -f manifest/lab/vpa-recommendation.yaml
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

## 🔁 Test Auto Mode ( DO NOT DO THIS! this is just for DEMO! )

### ✅ 1. Apply VPA with Auto Update

```bash
kubectl apply -f manifest/lab/vpa-auto.yaml
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

## 🧼 Cleanup

```bash
kubectl delete ns vpa-lab
```

---

## ✅ Validation Checklist

* VPA components installed successfully
* Sample deployment running
* VPA recommendation visible
* Resource requests updated (if Auto mode used)
