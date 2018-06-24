#!/bin/bash
set x

kubeadm init --pod-network-cidr=192.168.0.0/16

yes | cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml

kubectl taint nodes --all node-role.kubernetes.io/master-

kubectl apply -f istio-demo-auth.yaml

kubectl apply -f kubevirt.yaml

kubectl label namespace default istio-injection=enabled 

sleep 20

kubectl apply -f bookinfo.yaml

kubectl apply -f bookinfo-gateway.yaml
