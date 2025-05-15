# Lab 06: Deploying EFK Stack in K3s

## 🎯 Objective

In this lab, you will deploy a full EFK (Elasticsearch, Fluentd, Kibana) logging stack on a K3s cluster using Elastic Cloud on Kubernetes (ECK). This enables centralized log collection, search, and visualization from Kubernetes pods

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

* Add `fluentd-container*` indices into the DataView

1. Go to **Kibana > Stack Management > Data Views**
2. Click **"Create data view"**
3. Enter `ContainerLogs` as Name
3. Enter: `fluentd-container*` in Index Pattern
4. Set **Time field**: `@timestamp`
5. Save

* Add `fluentd-syslog*` indices into the DataView

1. Go to **Kibana > Stack Management > Data Views**
2. Click **"Create data view"**
3. Enter `SystemLogs` as Name
3. Enter: `fluentd-syslog*` in Index Pattern
4. Set **Time field**: `@timestamp`
5. Save

* Explore the Logs in Discover View

1. While in Kibana , navigate the Menu.
2. Navigate to Discover tab.
3. At the top left corner, you should able to see the Logs

---

### 9️⃣ Filter in Kibana for container that is producing Log `EFK Lab Log`

1. While in Discover
2. in the Filter write `kubernetes.pod_name : "log-generator"`
3. Clear the filter
4. in the Filter write `kubernetes.pod_name : "log-generator" and message : "*EFK Lab Log*"`

---

### 🔟 Don't STOP here!! 

Got it now, Steve — you want **Step 10** to be rewritten using the original context and tone (like KQL tips, field searches, wildcarding, etc.), but updated to use the **actual fields shown** in your screenshot (like `kubernetes.container_name`, `kubernetes.host`, `systemd_unit`, etc.).

Here's the rewritten **Step 🔟**:

---

### 🔟 Dive Deeper with Field-Level Searches in Kibana

Now that your logs are flowing into Kibana, it’s time to sharpen your search skills and extract meaningful insights using **KQL (Kibana Query Language)**.

You can use **field-level filters** and **free-text searches** to zero in on specific container logs, Elasticsearch node roles, or system-level activity from your K3s cluster.

---

#### 🔍 Free-Text Search

Run this in the Discover search bar:

```kql
"vm.max_map_count"
```

It will match any log message containing the text `vm.max_map_count`.

> **Note:** Quotes make it an exact match. No quotes = partial/fuzzy match.

---

#### 🔎 Field-Level Queries

Here are some real field-based searches based on your current schema:

| Goal                                                | Query                                                                   |
| --------------------------------------------------- | ----------------------------------------------------------------------- |
| Show all logs from container named `elasticsearch`  | `kubernetes.container_name : "elasticsearch"`                           |
| Match containers using image `elasticsearch:8.11.3` | `kubernetes.container_image : "*elasticsearch*"`                        |
| Logs from a specific K3s node                       | `kubernetes.host : "vmk3s001-stu01"`                                    |
| All logs from master-eligible Elasticsearch nodes   | `kubernetes.labels.elasticsearch.k8s.elastic.co/node-master : "true"`   |
| Logs from hot data Elasticsearch nodes              | `kubernetes.labels.elasticsearch.k8s.elastic.co/node-data_hot : "true"` |

---

#### 🧠 Wildcard Matching

KQL supports `*` and `?` for wildcards:

```kql
kubernetes.container_image : "*beat*"
```

Would match containers running any Beats (e.g., filebeat, metricbeat).

---

#### ⚠️ System-Level Log Search

You can find logs from systemd using:

```kql
systemd_unit : "k3s.service"
```

Or search across **all Elasticsearch-related units**:

```kql
systemd_unit : "*elasticsearch*"
```

---

#### ✅ Existence Check

Want to find logs that contain a specific field?

```kql
_exists_ : kubernetes.labels.elasticsearch.k8s.elastic.co/node-master
```

---

#### 🔁 Range Queries

Example to find logs by `uid` if it's numeric:

```kql
uid : [1000 TO 2000]
```

---

#### 🧨 Pro Tip

Want to find logs that are **not** from the data-hot nodes?

```kql
NOT kubernetes.labels.elasticsearch.k8s.elastic.co/node-data_hot : "true"
```

---

🧠 Remember: Case doesn’t matter in KQL, but wildcards do.
Use this section as your quick-fire arsenal during training or demos.