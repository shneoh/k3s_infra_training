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

---

### 2️⃣ Navigate to “Fleet” under Management

---

### 3️⃣ Setup Fleet (if not done already)



---

### 4️⃣ Download the Elastic Agent Installation Command

---

### 5️⃣ Deploy Elastic Agent as a DaemonSet in K3s

---

### 6️⃣ Verify Elastic Agent is Running on All Nodes

---

### 7️⃣ Navigate to “Integrations” and Search for Kubernetes

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