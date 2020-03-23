# -*- mode: ruby -*-
# vi: set ft=ruby :

NETWORK_BASE = "172.28.128"
INTEGRATION_START_SEGMENT_MASTER = 120
INTEGRATION_START_SEGMENT_WORKER = 130
LB_IP = "172.28.128.124"
SLB_IP = "172.28.128.125"

MASTER_COUNT = 3
WORKER_COUNT = 3

VAGRANT_BOX = 'ubuntu/xenial64'

Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false

  config.vm.provision "file", source: "~/Research/OS/vm/k8s-ha/k8s-ssh/authorized_keys", destination: "/home/vagrant/.ssh/authorized_keys"
  config.vm.provision "file", source: "~/Research/OS/vm/k8s-ha/k8s-ssh/config", destination: "/home/vagrant/.ssh/config"
  config.vm.provision "shell", inline: <<-SHELL
    sudo sed -i -e "\\#PasswordAuthentication yes# s#PasswordAuthentication yes#PasswordAuthentication no#g" /etc/ssh/sshd_config
    sudo systemctl restart sshd.service
    echo "finished ssh restarted"
  SHELL

  # define master
  (1..MASTER_COUNT-0).each do |i|
    config.vm.define "k8s-master0#{i}" do |master|
      master.vm.box = VAGRANT_BOX
      master.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = "2"
      end
      master.vm.network "private_network", ip: "#{NETWORK_BASE}.#{INTEGRATION_START_SEGMENT_MASTER + i}"
      master.vm.hostname = "k8s-master0#{i}"
      master.vm.provision "file", source: "~/Research/OS/vm/k8s-ha/k8s-ssh/master01.pub", destination: "/home/vagrant/.ssh/id_rsa.pub"
      master.vm.provision "file", source: "~/Research/OS/vm/k8s-ha/k8s-ssh/master01", destination: "/home/vagrant/.ssh/id_rsa"
      master.vm.provision "file", source: "~/Research/OS/vm/k8s-ha/k8s-setup/kubeadm/kubeadm-config.yaml", destination: "/home/vagrant/kubeadm-config.yaml"
      master.vm.provision "shell", inline: <<-SHELL
        chmod 400 /home/vagrant/.ssh/id_rsa
        chmod 400 /home/vagrant/.ssh/id_rsa.pub
        echo "finished ssh key permission"
      SHELL
      if i == MASTER_COUNT-0
        master.vm.provision "playbook1", type:'ansible' do |ansible|
          ansible.limit = "all"
          ansible.playbook = "k8s-setup/etcd-master.yml"
        end
        master.vm.provision "playbook2", type:'ansible' do |ansible|
          ansible.limit = "all"
          ansible.playbook = "k8s-setup/prerequites-playbook.yml"
        end
      end
    end
  end

  # define worker node
  (1..WORKER_COUNT-0).each do |i|
    config.vm.define "k8s-worker0#{i}" do |worker|
      worker.vm.box = VAGRANT_BOX
      worker.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = "1"
      end
      worker.vm.network "private_network", ip: "#{NETWORK_BASE}.#{INTEGRATION_START_SEGMENT_WORKER + i}"
      worker.vm.hostname = "k8s-worker0#{i}"
      worker.vm.provision "file", source: "~/Research/OS/vm/k8s-ha/k8s-ssh/node01.pub", destination: "/home/vagrant/.ssh/id_rsa.pub"
      worker.vm.provision "file", source: "~/Research/OS/vm/k8s-ha/k8s-ssh/node01", destination: "/home/vagrant/.ssh/id_rsa"
      worker.vm.provision "shell", inline: <<-SHELL
        chmod 400 /home/vagrant/.ssh/id_rsa
        chmod 400 /home/vagrant/.ssh/id_rsa.pub
        echo "finished ssh key permission"
      SHELL
      if i == WORKER_COUNT-0
        worker.vm.provision :ansible do |ansible|
          ansible.limit = "all"
          ansible.playbook = "k8s-setup/prerequites-playbook.yml"
        end
      end
    end
  end

  # Define loadbalancer
  config.vm.define "k8s-loadbalancer" do |lb|
    lb.vm.box = VAGRANT_BOX
    lb.vm.network "private_network", ip: "#{LB_IP}"
    lb.vm.hostname = "k8s-loadbalancer"
    lb.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.cpus = "1"
    end
    lb.vm.provision "file", source: "~/Research/OS/vm/k8s-ha/k8s-ssh/lb.pub", destination: "/home/vagrant/.ssh/id_rsa.pub"
    lb.vm.provision "file", source: "~/Research/OS/vm/k8s-ha/k8s-ssh/lb", destination: "/home/vagrant/.ssh/id_rsa"
    lb.vm.provision "shell", inline: <<-SHELL
      chmod 400 /home/vagrant/.ssh/id_rsa
      chmod 400 /home/vagrant/.ssh/id_rsa.pub
      echo "finished ssh key permission"
    SHELL
    lb.vm.provision "ansible" do |ansible|
      ansible.playbook = "k8s-setup/loadbalancer-playbook.yml"
    end  
  end

  # # Define internal loadbalancer 
  # config.vm.define "k8s-s-loadbalancer" do |slb|
  #   slb.vm.box = VAGRANT_BOX
  #   slb.vm.network "private_network", ip: "#{SLB_IP}"
  #   slb.vm.hostname = "k8s-slb"
  #   slb.vm.provider "virtualbox" do |vb|
  #     vb.memory = "512"
  #     vb.cpus = "1"
  #   end
  #   slb.vm.provision "file", source: "~/Research/OS/vm/k8s-ha/k8s-ssh/slb.pub", destination: "/home/vagrant/.ssh/id_rsa.pub"
  #   slb.vm.provision "file", source: "~/Research/OS/vm/k8s-ha/k8s-ssh/slb", destination: "/home/vagrant/.ssh/id_rsa"
  #   slb.vm.provision "file", source: "~/Research/OS/vm/k8s-ha/k8s-setup/ip_forward.sh", destination: "/home/vagrant/ip_forward.sh"
  #   slb.vm.provision "shell", inline: <<-SHELL
  #     chmod 400 /home/vagrant/.ssh/id_rsa
  #     chmod 400 /home/vagrant/.ssh/id_rsa.pub
  #     echo "finished ssh key permission"
  #   SHELL
  #   slb.vm.provision "ansible" do |ansible|
  #     ansible.playbook = "k8s-setup/internal-loadbalancer-playbook.yml"
  #   end   
  # end
end
