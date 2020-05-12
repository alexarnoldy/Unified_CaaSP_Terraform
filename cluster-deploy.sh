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
function func_exec_tf_action {
	cd ${TF_DIR}; terraform ${ACTION} -state=${STATE_DIR}/${KVM_HOST}.tfstate -var libvirt_user=${KVM_USER} -var libvirt_hostname=${KVM_HOST}&
}


DEPLOYorDESTROY="$(basename $0)"
[ $DEPLOYorDESTROY = cluster-destroy.sh ] && ACTION="destroy -auto-approve"


IFS=$'\n' read -r -d '' -a ALL_KVM_HOSTS < <( ls ./infrastructure && printf '\0' )

clear

echo "Select one or more of the following KVM hosts to target for CaaS Platform cluster deployment:"

for EACH in ${!ALL_KVM_HOSTS[@]}; do printf ${EACH}") "; echo "${ALL_KVM_HOSTS[EACH]}"; done


echo ""
echo "Acceptable input formats are a single number (i.e. 1),"
read -p "space separated list (i.e. 1 3), or a range (i.e. 2..4): " SELECTED_KVM_HOSTS

case ${SELECTED_KVM_HOSTS} in
       *..*)
	       for EACH in $(eval echo "{$SELECTED_KVM_HOSTS}")
	       do 
		       KVM_HOST="${ALL_KVM_HOSTS[EACH]}" 
		       KVM_USER=$(awk '/KVM_USER/ {print$2}' infrastructure/"${ALL_KVM_HOSTS[EACH]}") 
		       func_exec_tf_action
               done
               ;;

       *)
               for EACH in $(echo ${SELECTED_KVM_HOSTS})
               do
		       KVM_HOST="${ALL_KVM_HOSTS[EACH]}" 
		       KVM_USER=$(awk '/KVM_USER/ {print$2}' infrastructure/"${ALL_KVM_HOSTS[EACH]}") 
		       func_exec_tf_action
               done
               ;;
esac

