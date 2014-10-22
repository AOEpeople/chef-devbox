#!/bin/bash

function cleanup {
  logger "Removing temp dir ${TMPDIR}"
  rm -rf "${TMPDIR}"
}
trap cleanup EXIT

TMPDIR=`mktemp -d`
logger "Created temp dir: '${TMPDIR}'"

cd ~jenkins || { logger "Error while switching to ~jenkins" ; exit 1; }
tar -czf ${TMPDIR}/jenkins.tar.gz --exclude=builds/* --exclude=workspace/* --exclude=./.* --exclude=fingerprints ~jenkins || { logger "Error while creating tar" ; exit 1; }

logger "Uploading backup to S3";
/usr/local/bin/aws --profile XXXXXXXXXXXXXXXXXX s3 cp \
  "${TMPDIR}/jenkins.tar.gz" \
  "s3://XXXXXXXXXXXXXXXXXXXXXXXX/jenkins/jenkins_$(date '+%Y-%m-%d').tar.gz"  || { logger "Error while uploading backup to S3" ; exit 1; }
