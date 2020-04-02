## Introduction
This guide will walk you through the step by step process of deploying Sonatype Nexus OSS on a Kubernetes cluster.

# Setup Nexus OSS On Kubernetes
Key things to be noted,

- Nexus deployment and service are created in the devops-tools namespace. So make sure you have the namespace created or you can edit the YAML to deploy in a different namespace. Also, we have different deployment files for Nexus 2 & Nexus 3 versions.
- In this guide, we are using the volume mount for nexus data. For production workloads, you need to replace host volume mounts with persistent volumes.
- Service is exposed as NodePort. It can be replaced with LoadBalancer type on a cloud.

Let’s get started with the setup.

**Step 1:** Create a namespace called devops-tools

```bash
kubectl create namespace devops-tools
```

**Step 2:** Create a Deployment.yaml file. It is different for nexus 2.x and 3.x. We have given both. Create the YAML based on the Nexus version you need. Note: The images used in this deployment is from public official Sonatype docker repo.([Nexus2 image](https://hub.docker.com/r/sonatype/nexus/)  & [Dockerfile](https://github.com/sonatype/docker-nexus/blob/master/oss/Dockerfile) )  ([nexus 3 image](https://hub.docker.com/r/sonatype/nexus3/) & [Dockerfile](https://github.com/sonatype/docker-nexus3/blob/master/Dockerfile))

- **Deployment YAML for Nexus 2.x:** Here we are passing a few customizable ENV variable and adding a volume mount for nexus data.
```bash
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nexus
  namespace: devops-tools
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: nexus-server
    spec:
      containers:
        - name: nexus
          image: sonatype/nexus:latest
          env:
          - name: MAX_HEAP
            value: "800m"
          - name: MIN_HEAP
            value: "300m"
          resources:
            limits:
              memory: "4Gi"
              cpu: "1000m"
            requests:
              memory: "2Gi"
              cpu: "500m"
          ports:
            - containerPort: 8081
          volumeMounts:
            - name: nexus-data
              mountPath: /sonatype-work
      volumes:
        - name: nexus-data
          emptyDir: {}
```

- **Deployment YAML for Nexus 3.x:** Here we dont have any custom env variables. You can check the official docker repo for the supported env variables.
```bash

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nexus
  namespace: devops-tools
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: nexus-server
    spec:
      containers:
        - name: nexus
          image: sonatype/nexus3:latest
          resources:
            limits:
              memory: "4Gi"
              cpu: "1000m"
            requests:
              memory: "2Gi"
              cpu: "500m"
          ports:
            - containerPort: 8081
          volumeMounts:
            - name: nexus-data
              mountPath: /nexus-data
      volumes:
        - name: nexus-data
          emptyDir: {}
```

**Step 3:** Create the deployment using kubectl command.
```bash
kubectl create -f Deployment.yaml
```
Check the deployment pod status
```bash
kubectl get pods -n devops-tools
```

**Step 4:** Create a `Service.yaml` file with the following contents to expose the nexus endpoint using NodePort.

> **Note:** If you are on a cloud, you can expose the service using a load balancer using the service type Loadbalancer. Also, the Prometheus annotations will help in service endpoint monitoring by Prometheus.

```bash
apiVersion: v1
kind: Service
metadata:
  name: nexus-service
  namespace: devops-tools
  annotations:
      prometheus.io/scrape: 'true'
      prometheus.io/path:   /
      prometheus.io/port:   '8081'
spec:
  selector: 
    app: nexus-server
  type: NodePort  
  ports:
    - port: 8081
      targetPort: 8081
      nodePort: 32000
```

Check the service configuration using kubectl.
```bash
kubectl describe service nexus-service -n devops-tools
```

**Step 5:** Now you will be able to access nexus on any of the Kubernetes node IP on port 32000/nexus as we have exposed the node port. For example,

For Nexus 2,
```bash
http://<master IP>:32000/nexus
```

For Nexus 3,
```bash
http://<master IP>:32000
```

> **Note:** The default username and password will be admin & admin123

*Copyright(R):* https://devopscube.com/setup-nexus-kubernetes/