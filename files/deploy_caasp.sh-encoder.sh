#!/bin/bash

echo -n "    content: " > deploy_caasp-content.txt
gzip -c deploy_caasp.sh > deploy_caasp.sh.gz
./encoder.sh deploy_caasp.sh.gz
cat deploy_caasp-content.txt deploy_caasp.sh.gz.b64 > deploy_caasp.sh.gz.b64.tmp
mv deploy_caasp.sh.gz.b64.tmp deploy_caasp.sh.gz.b64
cat deploy_caasp.sh.gz.b64
