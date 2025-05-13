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
kubectl create secret generic elastic-credentials --from-literal=elastic=MyElasticPassword123
```

```sh
kubectl apply -f elasticsearch/elasticsearch-service.yaml
```
```sh 
kubectl get svc elasticsearch
```

```sh
kubectl apply -f elasticsearch/elasticsearch-statefulset.yaml
```
```sh 
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

```sh 
kubectl create secret -n kube-system generic elastic-credentials --from-literal=elastic=MyElasticPassword123 
```

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
kubectl get daemonsets -n kube-system | grep fluentd
```

Make sure one Fluentd pod is running per node.

--- 

### Verify fluentd is sending logs to elasticsearch 

```bash 
kubectl -n kube-system get pods -l name=fluentd

```

```bash 
kubectl exec -it jump1 -- sh

# export ES_USER=elastic
# export ES_PASS=MyElasticPassword123
# curl -u $ES_USER:$ES_PASS http://elasticsearch.default.svc:9200/_cat/indices?v
health status index               uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases    xoyVwlVuQHKx_Is08UPuLg   1   0         40            0     37.7mb         37.7mb
yellow open   logstash-2025.05.13 5nhPNVpQQ7-7J-Dz8BjVnQ   1   1      33776            0      4.7mb          4.7mb

# curl -u $ES_USER:$ES_PASS http://elasticsearch.default.svc:9200/logstash-*/_search?pretty

# exit 
```
>> if you get a output, it means fluentd is sending logs to elasticsearch 

---

### 3️⃣ Deploy Kibana

```bash
kubectl apply -f kibana/kibana-deployment.yaml
```
```sh 
kubectl apply -f kibana/kibana-service.yaml
```


## IMPORTANT, before applying kibana-ingress.yaml, edit the file and change the domain name!! 
>> host: kibana.app.stuXX.steven.asia  # 🔁 Change 'stuXX' to your student ID

>> kibana.app.stuXX.steven.asia      # 🔁 Change 'stuXX' to your student ID

```sh 
kubectl apply -f kibana/kibana-ingress.yaml
```
```sh 
kubectl get svc -l app=kibana
```

### Access Kibana via the Ingress.

```sh 
kubectl get ingress kibana-ingress -o jsonpath="{.spec.rules[0].host}" | xargs -I{} echo "https://{}"
```

### Configure Kibana index pattern
---
### Step1 


---
### Step2

---
### Step3


---
### Step4


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


