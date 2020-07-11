#!/bin/bash

LOG_FILE=/tmp/debug.log

sudo echo "Starting setup" >> $LOG_FILE

sudo sed -i -e 's/#DNS=/DNS=8.8.8.8/' /etc/systemd/resolved.conf
sudo echo "Copied dns entries" >> $LOG_FILE

sudo service systemd-resolved restart
sudo echo "Restarted systemd-resolved service" >> $LOG_FILE

sudo sysctl net.bridge.bridge-nf-call-iptables=1
sudo echo "Set sysctl iptables bridge" >> $LOG_FILE
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
sudo sysctl net.bridge.bridge-nf-call-ip6tables=1
sudo sysctl net.bridge.bridge-nf-call-iptables=1

sudo swapoff -a
sudo echo "Turned off swap" >> $LOG_FILE

cd /tmp
sudo curl -fsSL https://get.docker.com -o get-docker.sh
sudo echo "Fetched docker script" >> $LOG_FILE

sudo sh /tmp/get-docker.sh
sudo echo "Executed docker script" >> $LOG_FILE

IFNAME=$1
ADDRESS="$(ip -4 addr show $IFNAME | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
sudo sed -e "s/^.*${HOSTNAME}.*/${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts

# remove ubuntu-bionic entry
sudo sed -e '/^.*ubuntu-bionic.*/d' -i /etc/hosts

# Update /etc/hosts about other hosts
sudo echo "192.168.5.11  k8s-control-1" | sudo tee -a /etc/hosts
sudo echo "192.168.5.21  k8s-worker-1" | sudo tee -a /etc/hosts
sudo echo "192.168.5.22  k8s-worker-2" | sudo tee -a /etc/hosts
