#!/bin/sh -e

~/Code/Personal/jenkins-tools/bin/delete-job.sh virtual-box-tools || true
~/Code/Personal/jenkins-tools/bin/put-job.sh virtual-box-tools job.xml
