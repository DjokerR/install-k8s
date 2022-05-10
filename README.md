### 1、节点之间免密
~~~

cat << EOF >> /etc/hosts
 192.168.129.10 node10
 192.168.129.11 node11
 192.168.129.12 node12
EOF

ssh-keygen
ssh-copy-id root@node
~~~


###  2、关闭swap

~~~
swapoff -a
sed  -i -r '/swap/s/^/#/' /etc/fstab
~~~
###  3、关闭防火墙
~~~
setenforce 0
systemctl status firewalld.service 
systemctl stop firewalld.service

sed  -ri  's/SELINUX=enforcing/SELINUX=disable/' /etc/selinux/config
~~~

### 4、时间同步

~~~
yum  install -y chrony
systemctl enable chrony
systemctl restart chrony
timedatectl set-timezone Asia/Shanghai

~~~

### 5、内核参数优化
~~~
echo vm.max_map_count=262144>> /etc/sysctl.conf

echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf

sysctl -p
~~~

### 6、安装epel-release、kubernetes、docker 源
~~~
yum install epel-release -y
~~~

~~~

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

对于  aliyun源 gpg-key 验证失败
修改 
gpgcheck=0
repo_gpgcheck=0

yum list kubeadm --showduplicates | sort -r
优先安装kubelet kubectl kubeadm
注意！！！ kubeadm 安装会kubelet为1.24
yum install  kubelet-1.22.2-0 kubectl-1.22.2-0 kubeadm-1.22.2
~~~

#### step 1: 安装必要的一些系统工具
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
#### Step 2: 添加软件源信息
sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
#### Step 3
sudo sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
#### Step 4: 更新并安装Docker-CE
sudo yum makecache fast
sudo yum -y install docker-ce
yum install docker-ce-20.10.6-3.el7
#### Step 4: 开启Docker服务
sudo service docker start

~~~
# 注意：
# 官方软件源默认启用了最新的软件，您可以通过编辑软件源的方式获取各个版本的软件包。例如官方并没有将测试版本的软件源置为可用，您可以通过以下方式开启。同理可以开启各种测试版本等。
# vim /etc/yum.repos.d/docker-ce.repo
#   将[docker-ce-test]下方的enabled=0修改为enabled=1
#
# 安装指定版本的Docker-CE:
# Step 1: 查找Docker-CE的版本:
# yum list docker-ce.x86_64 --showduplicates | sort -r
#   Loading mirror speeds from cached hostfile
#   Loaded plugins: branch, fastestmirror, langpacks
#   docker-ce.x86_64            17.03.1.ce-1.el7.centos            docker-ce-stable
#   docker-ce.x86_64            17.03.1.ce-1.el7.centos            @docker-ce-stable
#   docker-ce.x86_64            17.03.0.ce-1.el7.centos            docker-ce-stable
#   Available Packages
# Step2: 安装指定版本的Docker-CE: (VERSION例如上面的17.03.0.ce.1-1.el7.centos)
# sudo yum -y install docker-ce-[VERSION]

使用 systemd 来管理容器的 cgroup
sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
~~~
#### 网络参数优化
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/ipv4/ip_forward

