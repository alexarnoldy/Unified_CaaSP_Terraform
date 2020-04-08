# URL of the libvirt server
# EXAMPLE:
# libvirt_uri = "qemu:///system"
libvirt_uri = ""

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

# CIDR of the network
#network_cidr = ""

# Number of lb nodes
lbs = 1

# 1 to deploy an admin node (required for automated deployment). 0 for no admin node
admins = 1

# Number of master nodes
masters = 1

# Number of worker nodes
workers = 2

# Name of DNS domain
#dns_domain = ""

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

# ssh keys to inject into all the nodes
# EXAMPLE:
# authorized_keys = [
#  "ssh-rsa <key-content>"
# ]
#authorized_keys = [
#  ""
#]

# IMPORTANT: Replace these ntp servers with ones from your infrastructure
ntp_servers = []
