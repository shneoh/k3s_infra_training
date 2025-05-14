# Lab 06: Deploying and Scaling EFK Stack in K3s

## 🎯 Objective

In this lab, you will deploy a full EFK (Elasticsearch, Fluentd, Kibana) logging stack on a K3s cluster using Elastic Cloud on Kubernetes (ECK). This enables centralized log collection, search, and visualization from Kubernetes pods.

---

## 🔄 Cleanup Before Starting

Clean up previous labs to free up resources:

```sh
kubectl get namespaces
````

```sh
kubectl delete namespaces app1
```

```sh
kubectl delete namespaces app2
```

```sh
kubectl delete namespaces redblue
```

```sh
kubectl delete ns demo-app
```

---

## 🧩 Step-by-Step Instructions

### 1️⃣ Install Elastic Operator

```sh
kubectl create -f https://download.elastic.co/downloads/eck/3.0.0/crds.yaml
```

```sh
kubectl apply -f https://download.elastic.co/downloads/eck/3.0.0/operator.yaml
```

---

### 2️⃣ Deploy Elasticsearch

```sh
kubectl create namespace logging
```

Apply `elasticsearch.yaml` manifest:

```sh
kubectl apply -f elasticsearch/elasticsearch.yaml
```

---

### 3️⃣ Retrieve `elastic` Password

```sh
kubectl get secret efk-es-elastic-user -n logging -o go-template='{{.data.elastic | base64decode}}'
```

---

### 4️⃣ Deploy Kibana

Apply `kibana.yaml` manifest:


```sh
kubectl apply -f kibana/kibana.yaml
```

Wait for the Kibana pod to be in `Running` state:

```sh
kubectl get pods -n logging -l kibana.k8s.elastic.co/name=kibana
```

---

### 5️⃣ Create Ingress for Kibana

Edit `kibana/kibana-ingress.yaml`  Update the domain to match your student ID and  Apply `kibana-ingress.yaml` :


```sh
kubectl apply -f kibana/kibana-ingress.yaml
```

Verify:

```sh
kubectl get ingress -n logging
```

Visit:

```sh
echo "https://kibana.app.stuXX.steven.asia"
```

Log in using:

* **Username**: `elastic`
* **Password**: use the value retrieved earlier

---

### 6️⃣ Deploy Fluentd

💡 Make sure to configure Fluentd properly to point to:

```
efk-es-http.logging.svc:9200
```

(You can reuse the original Fluentd config here, or ask Wolfden for an updated version)

---

### 7️⃣ Generate Logs for Testing

```sh
kubectl apply -f test/log-generator-pod.yaml
```

```sh
kubectl get pods -l app=log-generator
```

```sh
kubectl logs -f <log-generator-pod-name>
```

---

### 8️⃣ Validate Logs in Kibana

1. Open Kibana via browser.
2. Navigate to **Discover** tab.
3. Create an index pattern (e.g., `fluentd-*`).
4. Search and filter logs.

---

### 9️⃣ Cleanup (Optional)

```sh
kubectl delete -f test/log-generator-pod.yaml
```

```sh
kubectl delete -f kibana.yaml
```

```sh
kubectl delete -f elasticsearch.yaml
```

```sh
kubectl delete -f kibana-ingress.yaml
```

---

## 🧠 Notes

* ECK makes deploying and managing the Elastic stack much easier on Kubernetes.
* Passwords are stored in Kubernetes secrets.
* Kibana is secured by default, use the `elastic` user to log in.
* Use `kubectl port-forward` if you don't want Ingress access.

---
