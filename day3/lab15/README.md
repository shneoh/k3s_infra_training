# Lab 15: Deploying Container Apps with Linkerd injection

## 🎯 Objective

> ⚠️ This lab is designed for **k3s** and assumes you have a working cluster ready.

---
## 🛠️ Tasks Overview

---

## 🔧 Setup Instructions

### ✅ 1. Deploy Microservice 

* In this task, you will deploy a Sample YouTube Playlist MicroService
  >> This is a NOT a production Application!! You been WARNED!! 

---

* Create NS servicemesh-ns
```bash 
kubectl create ns servicemesh-ns
```
---
* Deploy Frontend web UI
```bash
kubectl create -f ./applications/videos-web/deploy.yaml
```
---
* Deploy Frontend Ingress 
* Edit the file and change the XX before deploying 
```bash
kubectl create -f ./applications/videos-web/videos-ingress.yaml
```
---
* Deploy the playlist api 
```bash
kubectl create -f ./applications/playlists-api/deploy.yaml
```
---
* Deploy the playlist api db

```bash
kubectl create -f ./applications/playlists-db/deploy.yaml
```
---
* Deploy Playlist Ingress 
* Edit the file and change the XX before deploying 
```bash
kubectl create -f ./applications/playlists-api/playlist-ingress.yaml
```
---
* Deploy the videos api and db

```bash
kubectl create -f ./applications/videos-db/deploy.yaml
```
---
* Deploy the videos api 
```bash
kubectl create -f ./applications/videos-api/deploy.yaml
```
---


### ✅ 2. Verify Deployment of Microservice

* Make sure all Pods are Running 
```bash
kubectl get all -n servicemesh-ns
```

* Make sure ingress in place for api(playlist) and web access (videos web) 
```sh 
kubectl get ingress -n servicemesh-ns
```

* Get the FQDN and browse to verify the App is working
```sh 
kubectl get ingress videos-web -n servicemesh-ns -o jsonpath="{.spec.rules[0].host}" | xargs -I{} echo "https://{}/home/"
```



### ✅ 3. PLACE
```bash

```

```sh 

```

```sh 

```

### ✅ 4. PLACE
```bash

```

### ✅ 5. PLACE 
```bash

```



---

## 🔁 PLACE

### ✅ 1. PLACE

```bash

```

### ✅ 2. PLACE

```bash

```


---

## 🧼 Cleanup

```bash

```

---

## ✅ Validation Checklist


