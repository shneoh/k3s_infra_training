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

Create a file called `elasticsearch.yaml` with the following content:

```yaml
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: efk
  namespace: logging
spec:
  version: 8.11.3
  nodeSets:
  - name: default
    count: 1
    config:
      node.store.allow_mmap: false
    volumeClaimTemplates:
    - metadata:
        name: elasticsearch-data
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 5Gi
  http:
    tls:
      selfSignedCertificate:
        disabled: true
```

Apply it:

```sh
kubectl apply -f elasticsearch.yaml
```

---

### 3️⃣ Retrieve `elastic` Password

```sh
kubectl get secret efk-es-elastic-user -n logging -o go-template='{{.data.elastic | base64decode}}'
```

---

### 4️⃣ Deploy Kibana

Create a file called `kibana.yaml` with this content:

```yaml
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: kibana
  namespace: logging
spec:
  version: 8.11.3
  count: 1
  elasticsearchRef:
    name: efk
  http:
    tls:
      selfSignedCertificate:
        disabled: true
```

Apply it:

```sh
kubectl apply -f kibana.yaml
```

Wait for the Kibana pod to be in `Running` state:

```sh
kubectl get pods -n logging -l kibana.k8s.elastic.co/name=kibana
```

---

### 5️⃣ Create Ingress for Kibana

Create a file called `kibana-ingress.yaml` and update the domain to match your student ID:

```yaml
---
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: kibana-https-redirect
  namespace: logging
spec:
  redirectScheme:
    scheme: https
    permanent: true
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kibana-ingress
  namespace: logging
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-staging
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    traefik.ingress.kubernetes.io/router.middlewares: logging-kibana-https-redirect@kubernetescrd
spec:
  rules:
  - host: kibana.app.stuXX.steven.asia  # 🔁 Replace stuXX
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kibana-kb-http
            port:
              number: 5601
  tls:
  - hosts:
    - kibana.app.stuXX.steven.asia
    secretName: kibana-tls
```

Then apply it:

```sh
kubectl apply -f kibana-ingress.yaml
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
