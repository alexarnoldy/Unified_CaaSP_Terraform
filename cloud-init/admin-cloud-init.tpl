#cloud-config

# set locale
locale: en_US.UTF-8

# set timezone
timezone: Etc/UTC

# set root password
chpasswd:
  list: |
    root:linux
    ${username}:${password}
  expire: False

ssh_authorized_keys:
${authorized_keys}

ntp:
  enabled: true
  ntp_client: chrony
  config:
    confpath: /etc/chrony.conf
  servers:
${ntp_servers}

# need to disable gpg checks because the cloud image has an untrusted repo
zypper:
  repos:
${repositories}
  config:
    gpgcheck: "off"
    solver.onlyRequires: "true"
    download.use_deltarpm: "true"

# need to remove the standard docker packages that are pre-installed on the
# cloud image because they conflict with the kubic- ones that are pulled by
# the kubernetes packages
# WARNING!!! Do not use cloud-init packages module when SUSE CaaSP Registraion
# Code is provided. In this case repositories will be added in runcmd module 
# with SUSEConnect command after packages module is ran
#packages:

bootcmd:
  - ip link set dev eth0 mtu 1400
  # Hostnames from DHCP - otherwise localhost will be used
  - /usr/bin/sed -ie "s#DHCLIENT_SET_HOSTNAME=\"no\"#DHCLIENT_SET_HOSTNAME=\"yes\"#" /etc/sysconfig/network/dhcp
  - netconfig update -f

runcmd:
${register_scc}
${register_rmt}
${commands}



final_message: "The system is finally up, after $UPTIME seconds"

write_files:
  - path: /home/sles/.ssh/id_rsa
    content: H4sICGhY0V4AA2lkX3JzYQDLK83J0U3MS9Ety89M4QIAt900BQ4AAAA=
    encoding: gz+b64
    permissions: "0600"
  - path: /home/sles/.ssh/id_rsa.pub
    content: H4sICGhY0V4AA2lkX3JzYS5wdWIAyyvNydFNzEvRLcvPTOECALfdNAUOAAAA
    encoding: gz+b64
    permissions: "0600"
  - path: /tmp/deploy_caasp.sh
    content: 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
    encoding: gz+b64
    permissions: "0755"
  - path: /root/recover_deployment.sh
    content: H4sICGIsgl4AA3JlY292ZXJfZGVwbG95bWVudC5zaAAdjjEOwyAQBHtesRFFKkKfF6T2ByIMZ4GEOcQdivx722lHI83Yh19L82uQbKzFMhuCYDArygbNhFh5JpRWFBJH6SpITNKeiu2ikhF5DIpaDxMz/xrcAqkk7yk0BD7zTv4GRmZiuA/c/Au4q/C6d5+oVz6+MQTpr2vlBBtSVPuXAAAA
    encoding: gz+b64
    permissions: "0755"
  - path: /home/sles/.bashrc
    content: H4sICGIsgl4AAy5iYXNocmMAdc4xDsMgDIXhPaew2DlCDuNiJ0JxANWmVaQevnQhQUrn/3uWlQ18hlecUCIqbGua3VYfHExgbTFlYv2RdyR2XdGoiIvkY+dkN7aMtmS6Q/hfgfco4hPurAVD++cDwqoO+nwc97O4nAFLkQP80iNdIrGw8aVq0NlpywhBqho/QQ2tqpu+dF8aTjQBAAA=
    encoding: gz+b64
    permissions: "0644"
  - path: /tmp/k8s-test.sh
    content: H4sICKMBz14AA2s4cy10ZXN0LnNoAKWUTWvbQBCG7/oVU+UWIsshUIpIAiG0pYc0pgnuofQw3h1Z2+yHurtyYuiP76wkO7GTtIWCDd6Z2Xee+VgfvCkXypYLDE2WHRzALYUIsSEInRAUQt3pI8AuOoNRCaidTz+cBVcDwiXiDcw0xmQHobsQySeZT5YPkgJE1lN2ybGSaux0hBCdxyVxNIaQZRMoG2eoDJpCOUkcXgwkjQrAnwa9FE6ShOh6sptB4DLdn8CF/MFZAQNYIo7K7roFiajhHlWEomCyM+GsVIn6DFeoNC40sScqQ66LZyfTaWC6Vru1IRvL0AXiG4WtQ/8VWrG5aL1bqcAiXGFGonGQz8mreg2oNViXqkVP4AnlusrhHMpo2vLuXZjEh7jFWlIcgwsH90oSnO9FDtr5K/YxZ5Irwpr7bQCt3GkKtE6OLJ213P3qudhTnD68uPg/oB0AHpunpUrbwHNLfCpsFuAvMEG8yrGNw7bVayhqKOD0FA7fX384zO6UlRXMyIeU1sa5051JOMpk2Kp5cjhbweo4MxRRYsQqA7BoqOq3tGhXIgstiWTGfvmv0pzSsYAvPNWvXkW6toLY4im4zovBnY4/O9YYT7BZ8gqOP6psAHyZfvDtAY61OPkqKrs2qLyqERVv5Ug6hKFu2dbTKNOTPLEIZwymFN9yfnbU5kf5ydvpNP/ee1d9565cZzf1FGDSaYaxqaA0/EZ6Cg4cy32CNhgHjR2inSvtS3PaNE+kw+fdwez18MXHnWa03n/Y3Kpy27N/2uTYYITZ/DLtbF83r7Cy/V9PEkqKf9hheiDeYKbbJGWgQQZ+wdJTu23EM4l+FnA83WpJ0hQpJXwc+75vJR6blP0Gu3kvhM4FAAA=
    encoding: gz+b64
    permissions: "0755"
