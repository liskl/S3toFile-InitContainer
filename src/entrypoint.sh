#!/usr/bin/env bash

set -euo pipefail;

echo "aws sts get-caller-identity:" ;
aws sts get-caller-identity ;

echo "Downloading \"s3://${S3_BUCKET}/${ENVIRONMENT}/version.txt\" to \"${LOCAL_DEST}\"" ;
/usr/bin/aws s3 cp s3://${S3_BUCKET}/${ENVIRONMENT}/version.txt ${LOCAL_DEST}/version.txt ;

VERSION="$( cat ${LOCAL_DEST}/version.txt )" ;

echo "Downloading s3://${S3_BUCKET}/${ENVIRONMENT}/*-${VERSION}.sql.gz to ${LOCAL_DEST}" ;
/usr/bin/aws s3 sync "s3://${S3_BUCKET}/${ENVIRONMENT}/" "${LOCAL_DEST}" --exclude "*" --include "*-${VERSION}.sql.gz";

rm -rf "${LOCAL_DEST}/version.txt";

set -x ;

for i in ${LOCAL_DEST}/*-data-${VERSION}.sql.gz; do mv -- "$i" "${i/*-data-/-01-data-}"; done
for i in ${LOCAL_DEST}/*-schema-${VERSION}.sql.gz; do mv -- "$i" "${i/*-schema-/-00-schema-}"; done

set +x ;

chown -R 1001:1001 "${LOCAL_DEST}" ;

find ${LOCAL_DEST} -type d -exec chmod 'go=rx,u=rwx' {} \;
find ${LOCAL_DEST} -type f -exec chmod 'u=rwx,go=rx' {} \;
find ${LOCAL_DEST} -type f -exec ls -alh {} \;

echo "Files transfered"
