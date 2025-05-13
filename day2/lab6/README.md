# Lab 06: Deploying and Scaling EFK Stack in K3s

## 🎯 Objective

In this lab, you will deploy a full EFK (Elasticsearch, Fluentd, Kibana) logging stack on a K3s cluster. This will enable centralized log collection, search, and visualization from Kubernetes pods.

---

## Before you start, please trace any previous lab activity and delete them to free some resources

```sh 
  kubectl get namespaces
```
```sh 
  kubectl delete namespaces app1
  kubectl delete namespaces app2
  kubectl delete namespaces redblue
  kubectl delete ns demo-app
```
>> The reason is to free resources and to keep the env clean for our next lab progress. 


---

## 🧩 Step-by-Step Instructions

### 1️⃣ Deploy Elasticsearch

```sh
kubectl apply -f elasticsearch/elasticsearch-service.yaml


kubectl get svc elasticsearch

```
```sh
kubectl apply -f elasticsearch/elasticsearch-statefulset.yaml


kubectl get pod -o wide

kubectl get pv

kubectl get pvc 
```

```sh 
kubectl get pods -l app=elasticsearch
```

Wait for the pod to be in `Running` state.

---

### 2️⃣ Deploy Fluentd as DaemonSet

```bash
kubectl apply -f fluentd/fluentd-serviceaccount.yaml
```
```sh 
kubectl apply -f fluentd/fluentd-clusterrole.yaml
kubectl apply -f fluentd/fluentd-clusterrolebinding.yaml

```
```sh 
kubectl apply -f fluentd/fluentd-configmap.yaml
```

```bash 
kubectl apply -f fluentd/fluentd-daemonset.yaml
```

```bash 
kubectl get daemonsets -n kube-system | grep fluentd
```

Make sure one Fluentd pod is running per node.

---

### 3️⃣ Deploy Kibana

```bash
kubectl apply -f kibana/kibana-deployment.yaml
kubectl apply -f kibana/kibana-service.yaml
kubectl get svc -l app=kibana
```

Access Kibana via the exposed NodePort or Ingress.

---

### 4️⃣ Generate Logs

```bash
kubectl apply -f test/log-generator-pod.yaml
kubectl get pods -l app=log-generator
kubectl logs -f <log-generator-pod-name>
```

This will create visible log data for Fluentd to collect.

---

### 5️⃣ Validate in Kibana

1. Open the Kibana dashboard in a browser.
2. Configure an index pattern (e.g., `fluentd-*`).
3. Query logs in Discover tab and validate log flow.

---

### 6️⃣ Cleanup (Optional)

```bash
kubectl delete -f test/log-generator-pod.yaml
kubectl delete -f kibana/
kubectl delete -f fluentd/
kubectl delete -f elasticsearch/
```

---

## 🧠 Notes

- Elasticsearch requires persistent storage. Tune requests/limits in production.
- Fluentd config must match log format written by container runtime (usually containerd in K3s).
- Ensure `log-generator` is writing logs to `stdout` to be picked up by Fluentd.
- Kibana can be exposed using NodePort or Ingress with TLS in production.


