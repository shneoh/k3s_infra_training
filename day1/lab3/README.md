# Lab 03: Service Exposure and Ingress Routing (K3s with Traefik)

## 📈 Objective

This lab demonstrates how services are exposed and routed in K3s using:

* ClusterIP and internal DNS
* NodePort access
* Simulated LoadBalancer behavior
* Traefik Ingress (DNS-based and path-based routing)

> All Ingress routes will resolve via `*.app.stuXX.steven.asia` pointing to your Load Balancer IP.

---

## 💡 Lab03A: ClusterIP + Internal DNS Access

1. Deploy kubia service and pods:

```bash
kubectl apply -f kubia.yaml
```

```bash 
kubectl apply -f kubia-svc.yaml
```

```bash 
kubectl apply -f jump_tool_pod.yaml
```

2. Inspect:

```bash
kubectl get pods -o wide
kubectl get svc
```

3. Test from jump pod:

```bash
kubectl exec -it jump1 -- sh
curl <pod-ip>:8080
curl <cluster-ip>
curl kubia
exit
```

---

## 💡 Lab03B: NodePort Access

1. Create NodePort service:

```bash
kubectl apply -f kubia-svc-nodeport.yaml
```

2. Get details:

```bash
kubectl get svc
kubectl get nodes -o wide
```

3. Test using internal IPs:

```bash
kubectl exec -it jump1 -- sh
curl <node-ip>:<nodeport>
exit
```

---

## 💡 Lab03C: Simulated LoadBalancer (Static IP via HAProxy)

> While K3s doesn’t natively support LoadBalancer services, we can simulate this using a manually defined external IP combined with HAProxy.

We simulate the LoadBalancer 

```bash 
kubectl apply -f kubia-svc-loadbalancer.yaml
```

```bash 
dig icecream.app.stuXX.steven.asia +short 
```
>> replace the XX with your student number
>> use the return Public IP on next Step 

```bash 
curl http://<PUBLIC_IP>:8081
```

---

## 💡 Lab03D: Ingress Routing (DNS-Based)

* Setup app1 using DNS Ingress

1. Deploy vote app v1 under app1 namespace:

```bash
cd ingress/app1
kubectl apply -f app1-namespace.yaml
kubectl apply -f app1-backend-vote.yaml
kubectl apply -f app1-backend-service.yaml
kubectl apply -f app1-frontend-vote.yaml
kubectl apply -f app1-frontend-service.yaml
```

2. Edit `app1-ingress.yaml`:

```yaml
host: app1.app.stuXX.steven.asia
```

3. Apply ingress:

```bash
kubectl apply -f app1-ingress.yaml
kubectl get ingress -n app1
```

4. Access in browser:

```bash
http://app1.app.stuXX.steven.asia
```

* Setup app2 using DNS Ingress

1. Deploy vote app v1 under app2 namespace:

```bash
cd ingress/app2
kubectl apply -f app2-namespace.yaml
kubectl apply -f app2-backend-vote.yaml
kubectl apply -f app2-backend-service.yaml
kubectl apply -f app2-frontend-vote.yaml
kubectl apply -f app2-frontend-service.yaml
```

2. Edit `app2-ingress.yaml`:

```yaml
host: app2.app.stuXX.steven.asia
```

3. Apply ingress:

```bash
kubectl apply -f app2-ingress.yaml
kubectl get ingress -n app2
```

4. Access in browser:

```bash
http://app2.app.stuXX.steven.asia
```

---

## 💡 Lab03E: Ingress Routing (Path-Based)

1. Deploy red/blue variant apps:

```bash
cd ingress/path-based-ingress
kubectl apply -f redblue-namespace.yaml
kubectl apply -f kubia-red-rc.yaml
kubectl apply -f kubia-red-svc.yaml
kubectl apply -f kubia-blue-rc.yaml
kubectl apply -f kubia-blue-svc.yaml
kubectl apply -f kubia-rb-ingress.yaml
```

2. Edit ingress host in `kubia-rb-ingress.yaml`:

```yaml
host: color.app.stuXX.steven.asia
```

3. Test access:

```
http://color.app.stuXX.steven.asia/red
http://color.app.stuXX.steven.asia/blue
```

---

## 🔐 Outcome

By the end of this lab, you should:

* Understand ClusterIP, NodePort, and Ingress exposure
* Use jump pods to test internal service discovery
* Route traffic using DNS-based and path-based Ingress rules
* Validate Traefik’s role as Ingress controller in K3s

---
