# Lab 06: Deploying and Scaling EFK Stack in K3s

## 🎯 Objective

In this lab, you will deploy a full EFK (Elasticsearch, Fluentd, Kibana) logging stack on a K3s cluster. This will enable centralized log collection, search, and visualization from Kubernetes pods.

---

## 🧱 Lab Structure

```
lab6/
├── elasticsearch/
│   ├── elasticsearch-deployment.yaml
│   └── elasticsearch-pvc.yaml
├── fluentd/
│   ├── fluentd-daemonset.yaml
│   └── fluentd-configmap.yaml
├── kibana/
│   ├── kibana-deployment.yaml
│   └── kibana-service.yaml
├── test/
│   └── log-generator-pod.yaml
└── README.md
```

---

## 🧩 Step-by-Step Instructions

### 1️⃣ Deploy Elasticsearch

```bash
kubectl apply -f elasticsearch/elasticsearch-pvc.yaml
kubectl apply -f elasticsearch/elasticsearch-deployment.yaml
kubectl get pods -l app=elasticsearch
```

Wait for the pod to be in `Running` state.

---

### 2️⃣ Deploy Fluentd as DaemonSet

```bash
kubectl apply -f fluentd/fluentd-configmap.yaml
kubectl apply -f fluentd/fluentd-daemonset.yaml
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


