#!/bin/bash

gzip -c deploy_caasp.sh > deploy_caasp.sh.gz
./encoder.sh deploy_caasp.sh.gz.b64
cat deploy_caasp.sh.gz.b64 