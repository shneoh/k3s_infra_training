# Lab 10: Kubernetes Network Policy Hands-On (Calico Stars Demo)

## 🌟 Objective

 Learn and apply Kubernetes NetworkPolicy for traffic control between frontend, backend, client, and management UI pods. This lab shows real-time visual feedback using a Internet exposed web UI.

---

## 🔧 Setup Instructions

### ✅ 1. Create Demo Environment

```bash
kubectl create -f demoapp/00-namespace.yaml
kubectl create -f demoapp/01-management-ui.yaml
kubectl create -f demoapp/02-backend.yaml
kubectl create -f demoapp/03-frontend.yaml
kubectl create -f demoapp/04-client.yaml
```

### ⌛ 2. Wait for Pods to be Ready

```bash
kubectl get pods --all-namespaces --watch
```

> ⚠️ It may take a few minutes to download images.

### 📃 3. Access the UI

* Edit the ui-ingress.yaml 
* Replace the stuXX with your student number and apply 

```bash 
kubectl create -f ui-ingress.yaml 
```
|| Rememeber to EDIT the file and change the XX value!! 


* Open `https://lab10.app.stuXX.steven.asia` in your browser
* You’ll see service nodes: `client (C)`, `frontend (F)`, and `backend (B)`
* By default, all nodes can communicate

---

## ⛔️ 4. Enable Isolation with Default Deny

```bash
kubectl create -n stars -f demoapp/default-deny.yaml
kubectl create -n client -f demoapp/default-deny.yaml
```

### 📊 Confirm Isolation

* Refresh the UI
* All services should disappear after a few seconds (UI is blocked from accessing them)

---

## 🔒 5. Allow UI Access to Pods

```bash
kubectl create -f demoapp/allow-ui.yaml
kubectl create -f demoapp/allow-ui-client.yaml
```

### ✅ Validate

* Refresh UI: Services reappear
* ⚠️ Services still cannot talk to each other

---

## 🔮 6. Allow Frontend ➡️ Backend

```bash
kubectl create -f demoapp/backend-policy.yaml
```

### ✅ Validate

* Refresh UI
* Only frontend (F) → backend (B) on TCP 6379 is allowed
* Backend ❌ frontend
* Client ❌ backend & frontend

---

## 🚪 7. Allow Client ➡️ Frontend

```bash
kubectl create -f demoapp/frontend-policy.yaml
```

### ✅ Final State:

* Client ✅ frontend
* Client ❌ backend
* Frontend ✅ backend
* No reverse traffic allowed from backend/frontend to client

---

## 🔐 Key Takeaways

* Default deny isolates workloads by default
* NetworkPolicy controls traffic at pod-level using labels
* Granular ingress policies improve microservice security

---

## 🧹 Cleanup (Optional)

```bash
kubectl delete ns client stars management-ui
```
