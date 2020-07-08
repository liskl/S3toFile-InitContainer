#!/bin/sh

set -euo pipefail;

echo "Downloading \"s3://${S3_BUCKET}/${ENVIRONMENT}/\" to \"${LOCAL_DEST}\""
/usr/bin/aws s3 sync "s3://${S3_BUCKET}/${ENVIRONMENT}/" "${LOCAL_DEST}" ;

chown -R 1001:1001 "${LOCAL_DEST}" ;

find ${LOCAL_DEST} -type d -exec chmod 'go=rx,u=rwx' {} \;
find ${LOCAL_DEST} -type f -exec chmod 'u=rwx,go=rx' {} \;
find ${LOCAL_DEST} -type f -exec ls -alh {} \;

echo "Files transfered"
