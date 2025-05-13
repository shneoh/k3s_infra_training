# Lab 05: Kubernetes Secrets and Config Security

## 🎯 Objective

In this lab, you'll explore how Kubernetes handles configuration and sensitive data. You'll work with container arguments, environment variables, ConfigMaps, and Secrets — both mounted and injected — to build real-world secure container deployments.

---

## 🧩 Lab05A: Passing an Argument in the Pod Definition

### Objective:
Understand how to pass startup arguments to a container in Kubernetes.

```bash
cat fortune-args/fortuneloop.sh
cat fortune-pod-args.yaml
# Modify the ARG value to change behavior
kubectl apply -f fortune-pod-args.yaml
```

```bash 
kubectl get pods -o wide
# Note the IP address of fortune pod
```

```bash 
kubectl exec -it jump1 -- sh
# curl <fortune_pod_ip>
# watch -n1 curl <fortune_pod_ip>
exit
```

```bash 
kubectl delete -f fortune-pod-args.yaml
```

---

## 🧩 Lab05B: Setting Environment Variables for a Container

### Objective:
Inject configuration into a pod using environment variables.

```bash
cat fortune-env/fortuneloop.sh
cat fortune-pod-env.yaml
```

```sh
kubectl create -f fortune-pod-env.yaml
```

```sh 
kubectl get pods -o wide
```

```sh 
kubectl exec -it jump1 -- sh
# curl <fortune_pod_ip>
# watch -n1 curl <fortune_pod_ip>

exit
```

---

## 🧩 Lab05C: Creating and Using ConfigMaps

### Objective:
Use Kubernetes ConfigMaps to manage non-sensitive app configuration.

```bash
kubectl create -f fortune-config.yaml
```
```sh 
kubectl get configmaps
```
```sh
kubectl get configmap fortune-config -o yaml
```
```sh
cat fortune-pod-env-configmap.yaml
```
```sh
kubectl apply -f fortune-pod-env-configmap.yaml
```
```sh
kubectl get pods -o wide
```
```sh
kubectl exec -it jump1 -- sh
# curl <fortune_pod_ip>
exit
```

---

## 🧩 Lab05D: Mounting ConfigMap as a Volume

### Objective:
Mount files from a ConfigMap into a container.

```bash
kubectl delete configmap fortune-config
```

```sh
ls -l configmap-files/
cat configmap-files/my-nginx-config.conf
cat configmap-files/sleep-interval
```

```sh
kubectl create configmap fortune-config --from-file=configmap-files
```
```sh
kubectl get configmap fortune-config -o yaml
```
```sh
cat fortune-pod-configmap-volume.yaml
```
```sh
kubectl create -f fortune-pod-configmap-volume.yaml
```
```sh
kubectl get pods -o wide
```
```sh
kubectl exec -it jump1 -- sh
# curl -H "Accept-Encoding: gzip" -I <POD_IP>
# exit
```

```sh
kubectl exec fortune-configmap-volume -c web-server -- ls /etc/nginx/conf.d
```

```sh
kubectl exec fortune-configmap-volume -c web-server -- ls /tmp/whole-fortune-config-volume
```

---

## 🧩 Lab05E: Creating Secrets and Enabling HTTPS

### Objective:
Use Kubernetes Secrets to securely store and use TLS certificates.

```bash
kubectl delete configmap fortune-config
```

```sh
cd fortune-https/
```

# Generate TLS certificate
```sh
openssl genrsa -out https.key 2048
openssl req -new -x509 -key https.key -out https.cert -days 3650 -subj /CN=www.kubia-example.com
```

```sh
# Create secret from key + cert
kubectl create secret generic fortune-https --from-file=https.key --from-file=https.cert --from-file=foo
kubectl get secret fortune-https -o yaml
```
```sh
ls -l configmap-files-https/
cat configmap-files-https/my-nginx-config.conf
cat configmap-files/sleep-interval
```

```sh
kubectl create configmap fortune-config --from-file=configmap-files-https
```
```sh
kubectl apply -f fortune-pod-https.yaml
```
```sh
kubectl get pods -o wide
```
```sh
kubectl exec -it jump1 -- sh
# curl https://<fortune-https_pod_ip> -k
# curl https://<fortune-https_pod_ip> -k -v
# exit
```

```sh
kubectl exec fortune-https -c web-server -- mount | grep certs
```

---

## 📌 Summary

- Use **args** to control container behavior dynamically.
- Use **env variables** for lightweight configuration.
- Use **ConfigMaps** for non-sensitive external config.
- Use **Secrets** for sensitive data like passwords and TLS certs.