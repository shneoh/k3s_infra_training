
# Lab11A

# Step 
Manage Jobs Resources 

```sh
kubectl get jobs

kubectl create -f batch-job.yaml

kubectl get po

kubectl logs batch-job-xxxxx

kubectl get job

kubectl create -f multi-completion-batch-job.yaml

kubectl create -f multi-completion-parallel-batch-job.yaml

kubectl get po


* Removed in new version ( use parallel in yaml def)
##kubectl scale job multi-completion-batch-job --replicas 3
```

# Lab11B

# Step 

```sh
kubectl get cronjobs

kubectl create -f  cronjob.yaml

kubectl get po 

kubectl get cronjobs
```
END