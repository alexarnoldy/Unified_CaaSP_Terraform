# URL of the libvirt server
# EXAMPLE:
# libvirt_uri = "qemu:///system"
libvirt_uri = ""


# Way of connecting to different KVM servers
# host_base is the hostname until a final number designator
#
#
#variable "libvirt_host_base" {
#variable "libvirt_host_number" {

# Path of the key file used to connect to the libvirt server
# Note this value will be appended to the libvirt_uri as a 'keyfile' query: <libvirt_uri>?keyfile=<libvirt_keyfile>
# EXAMPLE:
# libvirt_keyfile = "~/.ssh/custom_id"
libvirt_keyfile = ""

# URL of the image to use
# EXAMPLE:
# image_uri = "http://download.suse.com/..."
#image_uri = ""

# Identifier to make all your resources unique and avoid clashes with other users of this terraform project
#stack_name = ""


# CaaS Platform registration code ONLY when registering with SCC
#caasp_registry_code = ""

# RMT server to register against when NOT registering with SCC. Don't include http(s)://
#rmt_server_name = ""

# DNS domain of the cluster. This will also be used as the name of the CaaS Platform cluster for automated deployment
#dns_domain = ""

# CIDR of the network
#network_cidr = ""







# Deploy 0 load balancers when deploying on a single KVM host, and 1 when deploying across multiple KVM hosts (when it's available)
# Note that the admin node will eventually be configured to provide a single load balancer instance
lbs = 0
#lb_memory = 4096
#lb_vcpu = 1

# Set admins to 1 to deploy an admin node (required for automated deployment). 0 for no admin node
admins = 1
#admin_memory = 4096
#admin_vcpu = 2
# Admin node provides NFS peristent storage in and automated deployment. Adjust admin_disk_size if more storage is needed
#admin_disk_size = 25769803776

# Number of master nodes
masters = 1
#master_memory = 4096
#master_vcpu = 2

# Number of worker nodes
workers = 2
#worker_memory = 4096
#worker_vcpu = 2

# Username for the cluster nodes
# EXAMPLE:
#username = "sles"

# Password for the cluster nodes
# EXAMPLE:
#password = "linux"

# define the repositories to use
# EXAMPLE:
# repositories = {
#   repository1 = "http://example.my.repo.com/repository1/"
#   repository2 = "http://example.my.repo.com/repository2/"
# }
repositories = {}

# define the repositories to use for the loadbalancer node
# EXAMPLE:
# repositories = {
#   repository1 = "http://example.my.repo.com/repository3/"
#   repository2 = "http://example.my.repo.com/repository4/"
# }
lb_repositories = {}

# Minimum required packages. Do not remove them.
# Feel free to add more packages
#packages = [
#  "nfs-client",
#  "kernel-default",
#  "-kernel-default-base"
#]

# SSH keys to be injected into the cluster nodes. If deploying an admin node, should include the key from that node.
# EXAMPLE:
# authorized_keys = [
#  "ssh-rsa <key1-content>",
#  "ssh-rsa <key2-content>"
# ]
#authorized_keys = [
#  ""
#]

# IMPORTANT: Replace these ntp servers with ones from your infrastructure
#ntp_servers = []
