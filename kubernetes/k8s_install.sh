#!/bin/bash

# апдейтим систему и ставим нужные утилиты
apt update && apt -y upgrade && apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common

# смотрим на оперативку и своп
free -h
swapon -s

# свап надо вырубить, иначе kubeadm будет ругаться
echo "please manually edit /etc/fstab to adjust swap settings"
# nano /etc/fstab

# reboot нужен после правки fstab, но сам решай
# reboot

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# проверка, что модули вообще прогрузились
lsmod | egrep "br_netfilter|overlay"

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# ufw нафиг, иначе он всё к чертям порежет
systemctl stop ufw && systemctl disable ufw

export OS=xUbuntu_22.04
export CRIO_VERSION=1.25

echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /" | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list

# ключи для реп
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | apt-key add -

apt update && apt -y install cri-o cri-o-runc cri-tools

systemctl start crio && systemctl enable crio
systemctl status crio

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

# ставим kubelet, kubeadm, kubectl и морозим версии
apt update && apt -y install kubelet kubeadm kubectl && apt-mark hold kubelet kubeadm kubectl

# запускаем кластер, cidr под flannel
kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get nodes
kubectl get po -A

# flannel для сетки
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml

kubectl get po -n kube-flannel
