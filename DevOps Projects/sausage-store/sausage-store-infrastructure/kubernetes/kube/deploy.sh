#!/bin/sh
echo "checking if kubeconfig exists and removing if YES ..."
sudo rm -f /home/student/.kube/config ||true
echo "copying kubeconfig to /home/student/.kube ..."
sudo cp -rf config /home/student/.kube
sudo cp ./config /home/student/.kube/config ||true
sudo rm -f ./config
sudo chown -R student:student /home/student/.kube

echo "working on k8s context ..."
cd /home/student/.kube
kubectl config use-context student-context --kubeconfig=config
kubectl config set-context student-context --kubeconfig=config
sleep 5s

echo "switching to k8s directory ..."
cd /home/student/k8s

echo "starting backend & backend-report first  ..."
kubectl apply -f backend
sleep 5s
kubectl apply -f backend-report
sleep 5s

echo "starting frontend secondly ..."
kubectl apply -f frontend
sleep 10s

echo "starting ingress in the end ..."
kubectl apply -f ingress
sleep 10s

kubectl get pod -o wide

echo "removing kubeconfig ..."
sudo rm -f /home/student/.kube/config ||true