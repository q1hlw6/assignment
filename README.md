# Assignment for [REDACTED]

This repository contains the completed assignment for the [REDACTED] role at [REDACTED].
The sample application repository is published by the same user account.

## License

All contents of this repository are copyright of the author and may not be reproduced.

## Development

The code was developed in a standard macOS environment with these Homebrew packages and versions:

* `awscli` 2.1.28
* `terraform` 0.14.7
* `kubernetes-cli` 1.20.4
* `helm` 3.5.2

## Instructions

### Create Kubernetes cluster

Make sure you have all the right tools installed, credentials loaded, variables set, etc. Then:
```console
cd terraform
terraform init
terraform apply
```

You can fetch the kubeconfig for the new cluster using the AWS CLI:
```console
aws eks update-kubeconfig --name assignment
kubectl config get-contexts
kubectl get nodes
```

To allow connections from outside to web applications inside the cluster we will use a Kubernetes Ingress controller.
The [NGINX Ingress Controller](https://github.com/kubernetes/ingress-nginx) is easy to set up with Helm:
```console
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install -n default ingress-nginx ingress-nginx/ingress-nginx
```

### Deploy and configure Jenkins

Now you can install Jenkins using the custom Helm chart:
```console
helm install -n default jenkins ./helm/jenkins
```

The Jenkins server will be exposed to the internet through an Ingress resource.
Get the address with `kubectl`:
```console
kubectl get ingress/jenkins-master -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```
You will also need the initial admin password:
```console
kubectl exec deployment/jenkins-master -- cat /var/jenkins_home/secrets/initialAdminPassword
```

The Jenkins server has to be configured manually.
The pipeline for the sample application needs the following plugins:
* Pipeline
* Kubernetes
* Git
* Docker Pipeline

The Kubernetes plugin requires a Jenkins cloud configuration (*Manage Jenkins > Manage Nodes and Clouds > Configure Clouds*) to run agents.
All necessary values can be found in the Terraform output.
The Helm chart creates and assigns a Service Account which can be used as "Credentials" for the connection.

The repository for the sample application contains detailed instructions on how to set up the Jenkins pipeline.

### Deploy sample application with Helm

This repository contains a very minimal Helm chart to deploy the sample application to the EKS cluster after a succesful Jenkins build.

The only required value is the ECR registry name:
```console
DOCKER_REGISTRY_NAME=123456789012.dkr.ecr.eu-west-1.amazonaws.com
helm install -n default sample ./helm/sample --set image.registry=$DOCKER_REGISTRY_NAME
```
