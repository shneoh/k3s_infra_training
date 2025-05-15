# Lab 07: FluentD System Log Collection with K3s Journald

## 🌟 Objective

In this lab, you will configure FluentD to collect logs directly from the K3s system journal (`journald`) using the `systemd` input plugin. The goal is to parse control plane logs (including kubelet, kube-apiserver, etc.) from `k3s.service` and push them into Elasticsearch for centralized search and analysis in Kibana.

You will create dashboards and alerts around:

* Node status changes (e.g., `NotReady`, `Ready`)
* Control plane errors (e.g., pod sandbox failures)
* API server warnings and etcd-related events

---

## 🔧 Prerequisites

Ensure the following before proceeding:

1. **Persistent journald logs enabled**:

   * You need to run this command(s) on all nodes ( vmk3s001-stuXX, vmk3s002-stuXX, vmk3s003-stuXX )

   ```sh
   sudo mkdir -p /var/log/journal
   sudo systemd-tmpfiles --create --prefix /var/log/journal
   sudo systemctl restart systemd-journald
   sudo journalctl --disk-usage
   ```

   > This ensures logs survive node reboots and are accessible to FluentD.

2. Previous FluentD resources must be deleted:

   ```sh
   kubectl delete daemonset fluentd -n logging
   kubectl delete configmap fluentd-config -n logging
   ```

3. FluentD should run under the `logging` namespace.

---

## 🧠 Step-by-Step Instructions

### 1️⃣ Deploy FluentD for Journald Collection

Use the provided YAMLs in the `fluentd/` folder:

```sh
kubectl apply -f fluentd/lab7-fluentd-configmap.yaml
```

```sh
kubectl apply -f fluentd/lab7-fluentd-daemonset.yaml
```

This deploys FluentD with:

* `@type systemd` as the source
* Filters on `_SYSTEMD_UNIT=k3s.service`
* Index routing to `k3slogs-%Y.%m.%d`

Wait a moment, then verify FluentD pods are running:

```sh
kubectl -n logging get pods -l name=fluentd
```

---

### 2️⃣ Confirm Logs in Elasticsearch

Run the following from a fluentd pod :

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
yellow open   k3slogs-2025.05.14              9cs9-XnzQ9eLt_BpnV6S0A   1   1       1306            0      462kb          462kb        462kb

# exit 
```
>> if you get a output, it means fluentd is sending logs to elasticsearch 
>> look for k3slogs


You should see an index named:

```
k3slogs-YYYY.MM.DD
```

---

### 3️⃣ Create Data View in Kibana

1. Go to **Kibana > Stack Management > Data Views**
2. Click **"Create data view"**
3. Enter: `k3slogs-*`
4. Set **Time field**: `@timestamp`
5. Save

---

## 🎭 What to Visualize in Kibana

Use the Discover and Dashboard tabs to explore:

### 🎈 Pie Charts

* Node conditions: `Ready`, `NotReady`, etc.
* Error types: kubelet, etcd, apiserver

### 📊 Bar Charts

* Errors by component (e.g., kubelet vs controller)
* Node warnings per hostname

### 🔄 Timeline/Line Chart

* Control plane errors over time
* API access warnings or authentication failures

### 🔢 Table/Log View

* Raw k3s logs (structured and filterable)
* Group by severity level or keyword match

---

## ⚠️ Alerts (Optional)

Use Kibana's **Alerting > Rules** section to define:

* Rule: If `message` contains `Node .* is NotReady` in last 5 minutes
* Action: Log to Kibana or notify (if alerting stack is configured)

---

## 🔍 Verification

You can simulate events using `logger`:

```sh
logger "Node vmk3s001-stu01 is NotReady"
logger "E1001 Failed to pull image busybox"
```

Then watch in Discover.

---

## 🚀 END 