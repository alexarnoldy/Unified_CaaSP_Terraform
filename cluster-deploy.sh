#!/bin/bash

## Script to deploy CaaSP clusters via Terraform across a set group of KVM hosts

###
#Variables
###
TF_DIR=${PWD}
STATE_DIR=${PWD}/state
QEMU_USER=admin
QEMU_HOST_PREFIX=infra
DOMAIN=susecon.local
ACTION="apply -auto-approve"
###

DEPLOYorDESTROY="$(basename $0)"
[ $DEPLOYorDESTROY = cluster-destroy.sh ] && ACTION="destroy -auto-approve"

echo ""
echo "***IMPORTANT*** This script does not know the number of hosts you have"
echo "in your environment. Operating on the wrong hosts, too many hosts, "
echo "or hosts that don't exist can result in anything"
echo "from errors, to headaches, to an urgent desire to update to one's resume"
echo ""
echo "Enter the host numbers for deployment in formats of single number (i.e. 1),"
read -p "space separated list (i.e. 1 3), or range (i.e. 2..4): " HOSTS


case $HOSTS in
	*..*)
		eval '
		for EACH in {'"$HOSTS"'}; do
			#### Enable to deploy one node to a pre-existing public bridge. Can be used for a global cluster spanning KVM hosts
			### Update the IP address for the node to 240 + the KVM host "libvirt_host_number" and create the new network-*.cfg file
			#IPADDR=$(echo $((240+${EACH})))
			#sed "s/XYZ/${IPADDR}/" global-cluster-cloud-init/network.cfg > global-cluster-cloud-init/network-${EACH}.cfg
			cd ${TF_DIR}; terraform ${ACTION} -state=${STATE_DIR}/${QEMU_HOST_PREFIX}${EACH}.tfstate -var libvirt_host_number=${EACH}&
		done
		'
		;;
	*)
		for EACH in $(echo ${HOSTS})
		do
			#### Enable to deploy one node to a pre-existing public bridge. Can be used for a global cluster spanning KVM hosts
			## Update the IP address for the node to 240 + the KVM host "libvirt_host_number" and create the new network-*.cfg file
			#IPADDR=$(echo $((240+${EACH})))
			#sed "s/XYZ/${IPADDR}/" global-cluster-cloud-init/network.cfg > global-cluster-cloud-init/network-${EACH}.cfg
			cd ${TF_DIR}; terraform ${ACTION} -state=${STATE_DIR}/${QEMU_HOST_PREFIX}${EACH}.tfstate -var libvirt_host_number=${EACH}&
		done
		;;
esac

