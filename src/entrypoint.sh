#!/bin/sh

set -euo pipefail;

echo "Downloading \"s3://${S3_BUCKET}/${ENVIRONMENT}/version.txt\" to \"${LOCAL_DEST}\""
/usr/bin/aws s3 cp "s3://${S3_BUCKET}/${ENVIRONMENT}/version.txt" "${LOCAL_DEST}" ;

TIMESTAMP="$(cat "${LOCAL_DEST}/version.txt")"

echo "Downloading \"s3://${S3_BUCKET}/${ENVIRONMENT}/\*-${TIMESTAMP}.sql.gz" to \"${LOCAL_DEST}\""
/usr/bin/aws s3 sync "s3://${S3_BUCKET}/${ENVIRONMENT}/" "${LOCAL_DEST}" --exclude "*" --include "*-${TIMESTAMP}.sql.gz";

rm -rf "${LOCAL_DEST}/version.txt";

chown -R 1001:1001 "${LOCAL_DEST}" ;

find ${LOCAL_DEST} -type d -exec chmod 'go=rx,u=rwx' {} \;
find ${LOCAL_DEST} -type f -exec chmod 'u=rwx,go=rx' {} \;
find ${LOCAL_DEST} -type f -exec ls -alh {} \;

echo "Files transfered"
