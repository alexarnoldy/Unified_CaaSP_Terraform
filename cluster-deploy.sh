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

### NTS: 
### Need to change the state directory to be deployment oriented rather than host oriented.
### Have a directory in the state dir for each deployment.
### That dir will contain the state file for each KVM host used in that deployment plus
###   a file for the authorized_keys, the network prefix, and other custom components.
### The deployment will use -var's that cat the contents of those files, i.e. -var authorized_keys=$(cat state/${PREFIX}/authorized_keys)
function func_set_host.lock.file {
        until grep free host.lock.file; do (echo "waiting for host lock"; sleep 5); done
	echo ${KVM_HOST} > host.lock.file
}

function func_release_host.lock.file {
	echo free > host.lock.file
}

function func_update_ssh_keys_on_admin {
	sleep 30
	rm ./files/id_rsa* 
	ssh-keygen -q -t rsa -N '' -f files/id_rsa
	./files/file-gzip-encoder-load-in-cloud-init.sh ./files/id_rsa ./cloud-init/admin-cloud-init.tpl
	./files/file-gzip-encoder-load-in-cloud-init.sh ./files/id_rsa.pub ./cloud-init/admin-cloud-init.tpl
	sed -i -e "/^authorized_keys/{n;d}" terraform.tfvars
	sed -i -e "/^authorized_keys/a \"$(awk '/PUB_KEY/ {$1=""; print $0}' infrastructure/${KVM_HOST} | sed 's/^ //')\",\ \"$(cat files/id_rsa.pub)\"" terraform.tfvars
	rm ./files/id_rsa* 
}

function func_exec_tf_action {
	cd ${TF_DIR}; terraform ${ACTION} -state=${STATE_DIR}/${KVM_HOST}.tfstate -var libvirt_user=${KVM_USER} -var libvirt_hostname=${KVM_HOST}
}

function func_clear_ssh_keys {
	sleep 5
	echo "null-and-void" > files/id_rsa
	echo "null-and-void" > files/id_rsa.pub
	./files/file-gzip-encoder-load-in-cloud-init.sh ./files/id_rsa ./cloud-init/admin-cloud-init.tpl
	./files/file-gzip-encoder-load-in-cloud-init.sh ./files/id_rsa.pub ./cloud-init/admin-cloud-init.tpl
}

DEPLOYorDESTROY="$(basename $0)"
[ $DEPLOYorDESTROY = cluster-destroy.sh ] && ACTION="destroy -auto-approve"


IFS=$'\n' read -r -d '' -a ALL_KVM_HOSTS < <( ls ./infrastructure && printf '\0' )

clear

echo "Select one or more of the following KVM hosts to target for CaaS Platform cluster deployment:"

for EACH in ${!ALL_KVM_HOSTS[@]}; do printf ${EACH}") "; echo "${ALL_KVM_HOSTS[EACH]}"; done


echo ""
echo "Acceptable input formats are a single number (i.e. 0),"
read -p "space separated list (i.e. 1 3), or a range (i.e. 2..4): " SELECTED_KVM_HOSTS

case ${SELECTED_KVM_HOSTS} in
       *..*)
	       for EACH in $(eval echo "{$SELECTED_KVM_HOSTS}")
	       do 
		       KVM_HOST="${ALL_KVM_HOSTS[EACH]}" 
		       KVM_USER=$(awk '/KVM_USER/ {print$2}' infrastructure/"${ALL_KVM_HOSTS[EACH]}") 
		       [ $DEPLOYorDESTROY = cluster-deploy.sh ] && func_update_ssh_keys_on_admin
#		       [ $DEPLOYorDESTROY = cluster-deploy.sh ] && (func_set_host.lock.file; func_update_ssh_keys_on_admin; func_release_host.lock.file)
		       func_exec_tf_action
               done
               ;;

       *)
               for EACH in $(echo ${SELECTED_KVM_HOSTS})
               do
		       KVM_HOST="${ALL_KVM_HOSTS[EACH]}" 
		       KVM_USER=$(awk '/KVM_USER/ {print$2}' infrastructure/"${ALL_KVM_HOSTS[EACH]}") 
		       [ $DEPLOYorDESTROY = cluster-deploy.sh ] && func_update_ssh_keys_on_admin
#		       [ $DEPLOYorDESTROY = cluster-deploy.sh ] && (func_set_host.lock.file; func_update_ssh_keys_on_admin; func_release_host.lock.file)
		       func_exec_tf_action
               done
               ;;
esac

func_clear_ssh_keys
