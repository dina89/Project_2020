#!/usr/bin/env bash

#prepare bastion with aws cli and kubectl
sudo apt-get install unzip
curl 'https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'
unzip awscliv2.zip
sudo ./aws/install
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

#update kubeconfig
aws eks --region us-east-1 update-kubeconfig --name ${eks_cluster_name}

#install helm
curl -Ssl https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz -o helm-v${helm_version}-linux-amd64.tar.gz
tar -zxvf helm-v${helm_version}-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm


#download the consul helm chart
git clone --single-branch --branch v${consul_helm_version} https://github.com/hashicorp/consul-helm.git

#create gossip encryption secret
kubectl create secret generic consul-gossip-encryption-key --from-literal=key="${consul_secret}"

#update value.yml
sudo cp /tmp/values.yaml ./consul-helm/values.yaml

#install the helm chart
helm install hashicorp ./consul-helm

kubectl get svc <release-name>-consul-dns -o jsonpath='{.spec.clusterIP}'
KUBE_EDITOR="nano" kubectl edit configmap coredns -n kube-system

consul {
  errors
  cache 30
  forward . <consul-dns-service-cluster-ip>  for example 172.20.172.68 
}

variable "helm_version" {
  default = "3.2.0-rc.1"
}

variable "consul_helm_version" {
  default = "0.19.0"
}

variable "eks_cluster_name" {
  default = "opsSchool-eks-dina"
}

variable "consul_secret" {
  default = "uDBV4e+LbFW3019YKPxIrg=="
}

#install promcol node exporter
git clone https://github.com/helm/charts.git
helm install opsschool-nodeexporter ./charts/stable/prometheus-node-exporter

1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app=prometheus-node-exporter,release=opsschool-nodeexporter" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:9100 to use your application"
  kubectl port-forward --namespace default $POD_NAME 9100