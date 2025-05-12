# 🧪 Lab 4: Traefik Customization & HTTPS with Cert-Manager + Let's Encrypt

## 🎯 Objective

In this lab, you'll customize the default Traefik Ingress controller in your K3s cluster to automatically issue and manage TLS certificates for your apps using **cert-manager** and **Let's Encrypt**.

---

## 🛠️ Prerequisites

- A working K3s cluster with Traefik installed (default).
- DNS wildcard domain: `*.app.stuXX.steven.asia` pointing to your LB public IP.
- Access to the K3s cluster via `kubectl`.
- Internet access from your cluster nodes.

---

## 🧩 Step 1: Install cert-manager

Apply the cert-manager YAML manifest:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

Check that all cert-manager pods are up:

```bash
kubectl get pods -n cert-manager
```

---

## 🧩 Step 2: Create a ClusterIssuer (Let's Encrypt Staging)

Save the following manifest as `clusterissuer-staging.yaml`:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    email: your@email.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: traefik
```

Apply it:

```bash
kubectl apply -f clusterissuer-staging.yaml
```

---

## 🧩 Step 3: Deploy a Sample App

Create a namespace and deploy an nginx app:

```bash
kubectl create ns demo-app
kubectl create deployment web --image=nginx -n demo-app
kubectl expose deployment web --port=80 --target-port=80 -n demo-app
```

---

## 🧩 Step 4: Create an Ingress with TLS

Save this as `web-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: demo-app
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-staging
    kubernetes.io/ingress.class: traefik
spec:
  rules:
  - host: web.app.stuXX.steven.asia
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 80
  tls:
  - hosts:
    - web.app.stuXX.steven.asia
    secretName: web-tls
```

Apply the ingress:

```bash
kubectl apply -f web-ingress.yaml
```

---

## ✅ Step 5: Verify Certificate Issuance

Check the certificate status:

```bash
kubectl get certificate -n demo-app
kubectl describe certificate web-tls -n demo-app
```

Then open your browser and navigate to:

```
https://web.app.stuXX.steven.asia
```

If everything is successful, you should see the **nginx welcome page** served over HTTPS with a valid certificate (from Let's Encrypt staging).

---

## 🧹 Cleanup (Optional)

```bash
kubectl delete ns demo-app
kubectl delete clusterissuer letsencrypt-staging
```

---

## 📌 Notes

- This lab uses Let's Encrypt **staging** environment to avoid rate limits during testing.
- Replace `app.stuXX.steven.asia` with your actual DNS if testing manually.


