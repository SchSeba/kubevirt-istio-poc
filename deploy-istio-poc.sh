#!/bin/bash

set -x

kubeadm init --pod-network-cidr=192.168.0.0/16

yes | cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml

while [[ $(kubectl get po -n kube-system | grep kube-dns | grep Running | wc -l) -eq 0 ]}
do
        echo Calico deployment is no ready yet.
        sleep 5
done

echo Calico is ready.

echo Taint the master node.

kubectl taint nodes --all node-role.kubernetes.io/master-

echo Deploy kubevirt.

kubectl apply -f kubevirt.yaml

echo Deploy istio.

kubectl apply -f istio-demo-auth.yaml

echo Add istio-injection to the default namespace.

kubectl label namespace default istio-injection=enabled 

while [[ $(kubectl get po -n istio-system | grep sidecar-injector | grep Running | wc -l) -eq 0 ]]
do
        echo Istio deployment is no ready yet.
        sleep 5
done

echo Istio is ready.

sleep 20

echo Deploy the bookinfo example application

kubectl apply -f bookinfo.yaml

kubectl apply -f bookinfo-gateway.yaml