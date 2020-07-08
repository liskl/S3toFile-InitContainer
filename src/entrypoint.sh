#!/bin/sh

set -euo pipefail;

echo "Downloading \"s3://${S3_BUCKET}/${ENVIRONMENT}/\" to \"${LOCAL_DEST}\""
/usr/bin/aws s3 sync "s3://${S3_BUCKET}/${ENVIRONMENT}/" "${LOCAL_DEST}" ;

chown -R 1001:1001 "${LOCAL_DEST}" ;
chmod -R 644 "${LOCAL_DEST}/*.sql.gz" ;

echo "Files transfered"
find ${LOCAL_DEST} -type f -exec ls -alh {} \;
