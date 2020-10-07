# -*- mode: ruby -*-
# vi: set ft=ruby :

$kubeinit = <<-SCRIPT
sudo kubeadm init \
    --pod-network-cidr=10.244.0.0/16 \
    --apiserver-advertise-address=192.168.0.10 \
    --image-repository registry.aliyuncs.com/google_containers 2>&1 | tee kubeadm-init.log

sudo mkdir /root/.kube /home/vagrant/.kube
sudo cp /etc/kubernetes/admin.conf /root/.kube/config
sudo cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube

kubectl apply -f flannel.yml
SCRIPT



Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"

  # kube need 2 CPUs or more
  config.vm.provider "virtualbox" do |v|
      v.cpus = 2
  end

  config.vm.provision "shell", path: "boot.sh"

  config.vm.define "master", primary: true do |master|
      master.vm.hostname = "master"
      master.vm.network :private_network, ip: "192.168.0.10"

      master.vm.provision "file", source: "flannel.yml", destination: "flannel.yml"
      master.vm.provision "shell", inline: $kubeinit
  end

  config.vm.define "node1" do |node|
      node.vm.hostname = "node1"
      node.vm.network :private_network, ip: "192.168.0.11"
  end

  # config.vm.define "node2" do |node|
  #     node.vm.hostname = "node2"
  #     node.vm.network :private_network, ip: "192.168.0.12"
  #" end
end
