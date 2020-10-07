#!/bin/sh

set -xe

# disable swap
sudo swapoff -a

# use ustc mirrors
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bk
cat <<EOF | sudo tee /etc/apt/sources.list
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
EOF


# install container runtime -- docker
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/
sudo apt-get update && sudo apt-get install -y \
      apt-transport-https ca-certificates curl software-properties-common gnupg2

curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
    "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu \
    $(lsb_release -cs) stable"

sudo apt-get update && sudo apt-get install -y \
  containerd.io=1.2.13-2 \
  docker-ce=5:19.03.11~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:19.03.11~3-0~ubuntu-$(lsb_release -cs)

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "registry-mirrors": ["https://registry.docker-cn.co"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload
sudo systemctl restart docker


# install kube
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add - 
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl


# master init
# sudo kubeadm init \
#     --pod-network-cidr=10.244.0.0/16 \
#     --apiserver-advertise-address=192.168.0.10 \
#     --image-repository registry.cn-hangzhou.aliyuncs.com/google_containers 2>&1 | tee kubeadm-init.log
#

# install flannel plugin
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# use quay.io mirror
# kubectl apply -f flannel.yml


# node join
# kubeadm join 192.168.0.10:6443

# wait
# kubectl get pods -A
# kubectl get node

# test
# kubectl run mypod1 --image=busybox
# kubectl run mypod2 --image=busybox
# docker exec xxx ping xxx
