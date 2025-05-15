# Lab 08: Kibana & Alerting rules 

## 🌟 Objective

In this lab, you will configure Kibana. You will generate an Elastic Agent from Kibana and deploy it into your K3s environment to collect Kubernetes metrics and logs. These logs will be used for system observation, visualization, and creating alert rules for node health

---

## 🔧 Prerequisites

Ensure the following before proceeding:

1. **Elasticsearch and Kibana are installed and running**
2. **K3s cluster is operational and accessible**
3. **kubectl is configured and working**
4. **Internet access from the nodes (for pulling Elastic Agent)**

## 🧠 Step-by-Step Instructions


### 1️⃣ Login to Kibana Dashboard

* in case you need the password and the default username `elastic` 
```sh 
kubectl get secret efk-es-elastic-user -n logging -o go-template='{{.data.elastic | base64decode}}'
```
![alt text](image.png)



---

### 2️⃣ Navigate to `Add Integrations` under Menu

![alt text](image-1.png)


---

### 3️⃣ Add Kubernetes Integrations


![alt text](image-2.png)

---

![alt text](image-3.png)


---

### 4️⃣ Select all the Collection and `Save and Continue`

![alt text](image-4.png)


---

### 5️⃣ Once Kubernetes Integrations added, select `Add Elastic Agent to yout hosts`
![alt text](image-5.png)

---


### 6️⃣ Under Add Agent, select `Run Standalone` and `Copy the Yaml Manifest to your editor` 

* name the file as `elastic-agent-standalone-kubernetes.yml`


![alt text](image-6.png)


---

### 7️⃣ You need to add/update 3 directive in the agent manifest before running it

* The First one, you need to update the elastic host to your elastic host
* to get the fqdn, on your k3s run : 
```sh 
kubectl get svc efk-es-http -n logging -o jsonpath='{.metadata.name}.{.metadata.namespace}.svc.cluster.local'
```
---
![alt text](image-7.png)


---

* the image name under Daemonset, need to be updated to reflect the elastic and kibana version 

* the proper container image name is `elastic/elastic-agent:8:11.3` 


![alt text](image-8.png)


---


---



---


---
### 8️⃣ Add the Kubernetes Integration to Fleet

---

### 9️⃣ Select the Elastic Agent Policy and Add Kubernetes Logs + Metrics

---

### 🔟 Confirm K3s Logs are Ingested into Elasticsearch

---

### 1️⃣1️⃣ Create a New Data View in Kibana (e.g., `logs-*`)

---

### 1️⃣2️⃣ Open Discover Tab and Browse Incoming Logs

---

### 1️⃣3️⃣ Filter Logs by K3s Components (kubelet, containerd, etc.)

---

### 1️⃣4️⃣ Create a Dashboard to Visualize Node Metrics

---

### 1️⃣5️⃣ Navigate to “Stack Management” > “Rules and Connectors”

---

### 1️⃣6️⃣ Create New Rule for Node Down Alert

---

### 1️⃣7️⃣ Set Conditions: e.g., Agent is Offline or Node NotReady > 5m

---

### 1️⃣8️⃣ Add Action: Email, Slack, or Webhook Notification

---

### 1️⃣9️⃣ Save and Enable the Rule

---

### 2️⃣0️⃣ Simulate a Node Failure and Observe Alert Trigger

---

## 🚀 END