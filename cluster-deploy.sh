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

###
#Functions
###
#function func_exec_tf_action {
#	cd ${TF_DIR}; terraform ${ACTION} -state=${STATE_DIR}/${QEMU_HOST_PREFIX}${EACH}.tfstate -var libvirt_host_number=${EACH}&
#}
function func_exec_tf_action {
	cd ${TF_DIR}; terraform ${ACTION} -state=${STATE_DIR}/${KVM_HOST}.tfstate -var libvirt_user=${KVM_USER} -var libvirt_hostname=${KVM_HOST}&
}


DEPLOYorDESTROY="$(basename $0)"
[ $DEPLOYorDESTROY = cluster-destroy.sh ] && ACTION="destroy -auto-approve"

echo ""
echo "***IMPORTANT*** This script does not know the number of hosts you have"
echo "in your environment. Operating on the wrong hosts, too many hosts, "
echo "or hosts that don't exist can result in anything"
echo "from errors, to headaches, to an urgent desire to update to one's resume"
echo ""
#echo "Enter the host numbers for deployment in formats of single number (i.e. 1),"
#read -p "space separated list (i.e. 1 3), or range (i.e. 2..4): " HOSTS

IFS=$'\n' read -r -d '' -a options < <( ls ./infrastructure && printf '\0' )


clear
menu() {
    echo "Select the target KVM host(s):"
    for i in ${!options[@]}; do
        printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${options[i]}"
    done
    if [[ "$msg" ]]; then echo "$msg"; fi
}

prompt="Check an option (again to uncheck, ENTER when done): "
while menu && read -rp "$prompt" num && [[ "$num" ]]; do
    [[ "$num" != *[![:digit:]]* ]] &&
    (( num > 0 && num <= ${#options[@]} )) ||
    { msg="Invalid option: $num"; continue; }
    ((num--)); msg="${options[num]} was ${choices[num]:+un}checked"
    [[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
    clear
done

clear

for EACH in ${!options[@]}; do
#    [[ "${choices[EACH]}" ]] && { printf " %s" "${options[EACH]}"; msg=""; }
[[ "${choices[EACH]}" ]] && KVM_HOST="${options[EACH]}" && KVM_USER=$(awk '/KVM_USER/ {print$2}' infrastructure/"${options[EACH]}") && func_exec_tf_action
done



#case $HOSTS in
#	*..*)
#		eval '
#		for EACH in {'"$HOSTS"'}; do
#			#### START Enable to deploy one node to a pre-existing public bridge. Can be used for a global cluster spanning KVM hosts
#			### Update the IP address for the node to 240 + the KVM host "libvirt_host_number" and create the new network-*.cfg file
#			#IPADDR=$(echo $((240+${EACH})))
#			#sed "s/XYZ/${IPADDR}/" global-cluster-cloud-init/network.cfg > global-cluster-cloud-init/network-${EACH}.cfg
#			#### END Enable to deploy one node to a pre-existing public bridge. Can be used for a global cluster spanning KVM hosts
#			func_exec_tf_action
#		done
#		'
#		;;
#	*)
#		for EACH in $(echo ${HOSTS})
#		do
#			#### START Enable to deploy one node to a pre-existing public bridge. Can be used for a global cluster spanning KVM hosts
#			## Update the IP address for the node to 240 + the KVM host "libvirt_host_number" and create the new network-*.cfg file
#			#IPADDR=$(echo $((240+${EACH})))
#			#sed "s/XYZ/${IPADDR}/" global-cluster-cloud-init/network.cfg > global-cluster-cloud-init/network-${EACH}.cfg
#			#### END Enable to deploy one node to a pre-existing public bridge. Can be used for a global cluster spanning KVM hosts
#			func_exec_tf_action
#		done
#		;;
#esac

