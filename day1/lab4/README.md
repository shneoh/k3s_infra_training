# Lab 04: Traefik Customization & HTTPS with Cert-Manager + Let's Encrypt

## 🎯 Objective 1

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

## 🧩 Step 4: Create a Traefik Middleware to enable http to httpd redirect

Apply the middleware:

```bash
kubectl apply -f middleware-traefik.yaml
```
---

## 🧩 Step 5: Create an Ingress with TLS

Apply the ingress:

```bash
kubectl apply -f web-ingress.yaml
```
>> edit the file web-ingress.yaml and update your stuXX number!! 

---

## ✅ Step 6: Verify Certificate Issuance

Check the certificate status:

```bash
kubectl get certificate -n demo-app
kubectl describe certificate web-tls -n demo-app
```

Then open your browser and navigate to:

```
https://web.app.stuXX.steven.asia
```
>> replace XX with your student number

If everything is successful, you should see the **nginx welcome page** served over HTTPS with a valid certificate (from Let's Encrypt staging).

---

## 🎯 Objective 2

In this part, you'll enable Basic Auth using Traefik Ingress to Secure Public Access to LongHorn CSI Management.

---

## 🛠️ Prerequisites

- A working K3s cluster with Traefik installed (default).
- A working LongHorn CSI installed and plugged into k3s

---

## 🧩 Step 1: Create user/password hash using htpasswd and Kubernetes secret

* Change the username `steven` to your name
* Change the password to your liking

```sh 
htpasswd -nb steven DumbDumbWillgoPumpPump | openssl base64
```
>> copy the hash
>> if the command `htpasswd` not found, then, take a `flight (MAS/Airasia)` to `Ubuntu Canonical HQ`, and ask them to install it for you!

* edit the file longhorn-secret.yaml and add the hash
* replace the `XXXXXXXX` hash placeholder
* Apply the manifest

```sh 
kubectl apply -f longhorn-secret.yaml 
```


## 🧩 Step 2: Create traefik middleware for Auth

```sh 
kubectl apply -f mid-auth.yaml
```


## 🧩 Step 3: Create traefik middleware for http to https redirection

```sh 
kubectl apply -f mid-https.yaml
```

* Verify both traefik middleware are in place

```sh 
kubectl get middleware -n longhorn-system
```
## 🧩 Step 4: Edit `longhorn-ingress.yaml` 
*  replace your `stuXX` with your `student number`

```sh 
    ## Change the XX to your student number
  - host: longhorn.app.stuXX.steven.asia

```

```sh 
  ## Change the XX to your student number
    - longhorn.app.stuXX.steven.asia

```

* Apply the longhorn-ingress.yaml 

```sh 
kubectl apply -f longhorn-ingress.yaml
```

* Verify ingress and Certificate are created
```sh 
kubectl get ingress -n longhorn-system
```

```sh 
kubectl get certificate -n longhorn-system
```


## 🧩 Step 5: Once the ingress and certificate created, access the LongHorn Ui 

* Get the web link 

```sh 
kubectl get ingress longhorn-ingress -n longhorn-system -o jsonpath="{.spec.rules[0].host}" | xargs -I{} echo "https://{}"
```

## 🧩 Step 6: Access the Longhorn UI with your Username and Password from Secret

---


---



---

## 🧹 Cleanup (Optional)

```bash
kubectl delete ns demo-app
kubectl delete clusterissuer letsencrypt-staging
```

---

## 📌 Notes

- This lab uses Let's Encrypt **staging** environment to avoid rate limits during training/testing.
- This training is not about LongHorn!! its about Traefik/Https/TLS/Ingress/Middleware

