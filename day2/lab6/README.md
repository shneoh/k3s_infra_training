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
kubectl create -f eck-ops/crds.yaml
```

```sh
kubectl apply -f eck-ops/operator.yaml
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

Wait for the Kibana and elastic pod to be in `Running` state and shows `1/1 READY`:

```sh
kubectl get pod -n logging --watch 
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

```bash 
kubectl get ingress kibana-ingress -n logging -o jsonpath="{.spec.rules[0].host}" | xargs -I{} echo "https://{}"
```

Log in using:

* **Username**: `elastic`
* **Password**: use the value retrieved earlier

 >> **kubectl get secret efk-es-elastic-user -n logging -o go-template='{{.data.elastic | base64decode}}'**
---

### 6️⃣ Deploy Fluentd

💡 Make sure elastic and kibana are fully functional

```bash
kubectl apply -f fluentd/fluentd-serviceaccount.yaml
```
```sh 
kubectl apply -f fluentd/fluentd-clusterrole.yaml
```

```sh 
kubectl apply -f fluentd/fluentd-clusterrolebinding.yaml
```
```sh 
kubectl apply -f fluentd/fluentd-configmap.yaml
```
```bash 
kubectl apply -f fluentd/fluentd-daemonset.yaml
```
```bash 
kubectl get daemonsets -n logging | grep fluentd
```

```sh 
kubectl -n logging get pods -l name=fluentd
```

```bash 
kubectl exec -it fluentd-XXXXX -n logging  -- sh
```
>> use any of the pod from previous output 

```sh 
# apt-get update && apt-get install curl -y
# 
# curl -u $FLUENT_ELASTICSEARCH_USER:$FLUENT_ELASTICSEARCH_PASS http://$FLUENT_ELASTICSEARCH_HOST:$FLUENT_ELASTICSEARCH_PORT/_cat/indices?v

health status index                           uuid                    pri rep docs.count docs.deleted store.size pri.store.size dataset.size
yellow open   fluentd-container-2025.05.14    rZ_dH4toSaiA7V7Fw2Om8w   1   1       1879            0    953.2kb        953.2kb      953.2kb
yellow open   fluentd-syslog-2025.05.14       o9DIpxbHREimHjBwThesuQ   1   1       1482            0    374.1kb        374.1kb      374.1kb

# exit 
```
>> if you get a output, it means fluentd is sending logs to elasticsearch 
>> look for fluentd-* logs 

---

### 7️⃣ Generate Logs for Testing

```sh
kubectl apply -f test/log-generator-pod.yaml
```

```sh
kubectl get pods -l app=log-generator
```

```sh
kubectl logs -f log-generator
```

---

### 8️⃣ Validate Logs in Kibana

1. Open Kibana via browser.
2. Navigate to **Discover** tab.
3. Create an index pattern (e.g., `fluentd-container*`).
4. Search and filter logs. using KQL 

```kql
kubernetes.pod_name : "log-generator"
```
---
