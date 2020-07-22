FROM scratch
ADD src/alpine-minirootfs-3.12.0-x86_64.tar.gz /

# inject env variables into Pod
#ENV AWS_ACCESS_KEY_ID
#ENV AWS_SECRET_ACCESS_KEY
#ENV AWS_REGION

#ENV S3_BUCKET
ENV ENVIRONMENT "dev"
ENV LOCAL_DEST "/destination"

RUN apk update && apk add --no-cache bash aws-cli
RUN mkdir -p ${LOCAL_DEST}

VOLUME ${LOCAL_DEST}

COPY "src/entrypoint.sh" "/entrypoint.sh"

CMD ["/bin/sh", "-C", "/entrypoint.sh"]
