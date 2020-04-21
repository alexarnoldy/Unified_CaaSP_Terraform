#!/bin/bash

#### Script to deploy CaaSP from a CaaSP admin node, principally developed around deploying the nodes with Terraform libvirt provider
#### Script is based on using a central set of SSH keys 
#### If using this with Terraform deployed cluster nodes, need to make sure the
#### keys used by the admin node are populated in the cluster nodes' /home/sles/.ssh/authorized_keys file
#### If using this with a Terraform deployed admin node, need to forward the keys to the admin node

## Generate the /home/sles/.all_nodes file
## Alternate way if ipcalc is not available: nmap -sL $(ip a | grep eth0$ | awk '{print$2}') | grep \)$ | awk '{print$5}' > /home/sles/.all_nodes

## NETWORK variable is consumed here and while setting up the NFS StorageClass
NETWORK=$(ipcalc $(ip a | grep eth0$ | awk '{print$2}') | awk '/Network:/{print$2}')
nmap -sL ${NETWORK} | grep \)$ | awk '{print$5}' > /home/sles/.all_nodes


## Generate the /home/sles/.ssh/config file
rm -f /home/sles/.ssh/config 
for EACH in $(cat /home/sles/.all_nodes) 
do 
	echo "HOST $EACH $(echo $EACH | awk -F. '{print$1}')" >> /home/sles/.ssh/config 
	echo "  HOSTNAME $EACH" >> /home/sles/.ssh/config
done



## Verify time skew across the cluster
date +%s > /tmp/time-check
for EACH in `cat /home/sles/.all_nodes`
do bash -c "ssh $EACH date +%s >> /tmp/time-check & "
done
sort /tmp/time-check > /tmp/time-check.tmp
mv /tmp/time-check.tmp /tmp/time-check
[ $(echo $(($(tail -1 /tmp/time-check) - $(head -1 /tmp/time-check)))) -gt 2 ] && echo "Time skew greater than 2 seconds. Exiting" && exit
rm /tmp/time-check



CLUSTER_NAME=$(grep master /home/sles/.all_nodes | head -1 | awk -F. '{print$2}')

## Makes the script idempotent so it can safely run at every boot (a side effect of having to reboot the admin node before running this script)
## An alternative to explore would be to move the script out of /var/lib/cloud/scripts/per-boot if the cluster directory is found
if [ -d /home/sles/${CLUSTER_NAME} ] 
then
	echo "Cluster is already initialized. Exiting"
	exit
fi


eval $(ssh-agent)
ssh-add /home/sles/.ssh/id_rsa

## Populates the known_hosts file with the FQDN of the cluster nodes
### To ssh with an alias or short name, create a .ssh/config entry for 
### each node where HOST points to the alias and HOSTNAME points to the FQDN
ssh-keyscan -H -f /home/sles/.all_nodes > /home/sles/.ssh/known_hosts


## Initialize a new cluster
### Set API_ENDPOINT to the FQDN of the load balancer VIP or of the master in case of a single master deployment
#API_ENDPOINT=master-0.caasp-susecon.lab
API_ENDPOINT=$(grep master /home/sles/.all_nodes | head -1)
## CLUSTER_NAME is populated at the beginning of the script

cd /home/sles; skuba cluster init --control-plane ${API_ENDPOINT} ${CLUSTER_NAME}
cd $CLUSTER_NAME


## Bootstrap the cluster with the first master node listed in /home/sles/.all_nodes
MASTER_FQDN=$(grep master /home/sles/.all_nodes | head -1)
MASTER=$(echo $MASTER_FQDN | awk -F. '{print$1}')

## Ensure the first master node is responding on port 22
## May add same test to every join but for now assuming that if the first master is up, the rest are also up
until nc -zv ${MASTER_FQDN} 22; do echo "waiting for ${MASTER_FQDN}" && sleep 5; done
skuba node bootstrap --user sles --sudo --target ${MASTER_FQDN} ${MASTER}

## Join the remaining master nodes to the cluster
### Will simply bypass in the case of a single master deployment
for MASTER_FQDN in `grep master /home/sles/.all_nodes | tail -n+2`; do \
MASTER=`echo $MASTER_FQDN | awk -F. '{print$1}'`; \
skuba node join --role master --user sles --sudo \
--target $MASTER_FQDN $MASTER; \
done

## Join the worker nodes to the cluster
for WORKER_FQDN in `grep worker /home/sles/.all_nodes`; do \
WORKER=`echo $WORKER_FQDN | awk -F. '{print$1}'`; \
skuba node join --role worker --user sles --sudo \
--target $WORKER_FQDN $WORKER; \
done

########
#### Uncomment to point to RMT server that is also providing helm charts
########
#RMT_SERVER=$(awk -F/ '/url/ {print$3}' /etc/SUSEConnect)
#helm repo add internal_helm https://charts.${RMT_SERVER}
########

## Generate the /etc/exports and /etc/idmapd.conf files for NFS service
sudo bash -c "echo /public ${NETWORK}\(rw,no_root_squash\) > /etc/exports"

DOMAINNAME=$(hostname -f  | sed "s/$(hostname)\.//")
sudo bash -c "cat <<EOF>/etc/idmap.conf
[General]

Verbosity = 0
Pipefs-Directory = /var/lib/nfs/rpc_pipefs
Domain = ${DOMAINNAME}

[Mapping]

Nobody-User = nobody
Nobody-Group = nobody
EOF"

## (Re)start and enable NFS server
sudo systemctl stop nfs-server.service
sudo systemctl --now --no-block enable nfs-server

## Create NFS Storage Class
export KUBECONFIG=${HOME}/${CLUSTER_NAME}/admin.conf
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller \
    --clusterrole=cluster-admin \
    --serviceaccount=kube-system:tiller
helm init \
    --tiller-image registry.suse.com/caasp/v4/helm-tiller:2.16.1 \
    --service-account tiller
kubectl -n kube-system wait --for=condition=available --timeout=300s deployment/tiller-deploy
#sleep 60
until sudo showmount -e; do echo "NFS server not ready"; done
IP_ADDR=$(ip a | grep eth0$ | awk '/inet/ {print$2}' | awk -F/ '{print$1}')
helm install --name susecon-nfs stable/nfs-client-provisioner --set nfs.server=${IP_ADDR} --set nfs.path=/public
kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

## Kill ssh-agent
kill ${SSH_AGENT_PID}



echo export KUBECONFIG=${HOME}/${CLUSTER_NAME}/admin.conf >> /home/sles/.bashrc
#cat<<EOF>> /home/sles/.bashrc
#set -o vi
#alias kgn="kubectl get nodes -o wide"
#alias kgd="kubectl get deployments -o wide"
#alias kgp="kubectl get pods -o wide"
#alias kgpa="kubectl get pods -o wide --all-namespaces"
#alias kaf="kubectl apply -f"
#EOF

. /home/sles/.bashrc
cd ${HOME}/${CLUSTER_NAME}; skuba cluster status
kubectl get nodes -o wide


