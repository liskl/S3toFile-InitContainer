# global service name
SERVICE                 := s3tofile

REGISTRY                := registry.ciitizen.net
REGISTRY_PATH           := util

SHELL                   := /bin/bash

APP_VERSION             := $(shell echo `git-semver -prefix v`)
GIT_VERSION          		?= $(shell echo `git rev-parse --short HEAD`)
GIT_BRANCH              ?= $(shell echo `git rev-parse --abbrev-ref HEAD | sed "s,/,-,g" | sed "s,_,-,g"`)

IMAGE_NAME              := $(REGISTRY)/$(REGISTRY_PATH)/$(SERVICE)
IMAGE_TAG               := $(APP_VERSION)-g$(GIT_VERSION)

FULL_IMAGE              := $(IMAGE_NAME):$(IMAGE_TAG)

ROLE_ARN                := $(shell echo `aws --profile=custctzn-dev iam list-roles | jq -r '.[][] | select(.RoleName | contains("SharedServicesAccountAccessRole")) | .Arn'`)
ROLE_CREDS              := $(shell echo `aws --profile=custctzn-dev sts assume-role --role-arn="${ROLE_ARN}" --role-session-name=svc-s3tofile --output=json | jq -cr '.'`)


AWS_ACCESS_KEY_ID       := $(shell echo '$(ROLE_CREDS)' | jq -rc '.Credentials.AccessKeyId')
AWS_SECRET_ACCESS_KEY   := $(shell echo '${ROLE_CREDS}' | jq -rc '.Credentials.SecretAccessKey')
AWS_SESSION_TOKEN       := $(shell echo '${ROLE_CREDS}' | jq -rc '.Credentials.SessionToken')

preflight:
	echo "Preflight Checks:";
	@echo -ne "\t$$(which git)\n"
	@echo -ne "\t$$(which jq)\n"
	@echo -ne "\t$$(which aws)\n"

testnumb: preflight
	@export AWS_ACCESS_KEY_ID="$(AWS_ACCESS_KEY_ID)" && \
	export AWS_SECRET_ACCESS_KEY="$(AWS_SECRET_ACCESS_KEY)" && \
	export AWS_SESSION_TOKEN="$(AWS_SESSION_TOKEN)" && \
	echo -ne "ROLE: " && \
	aws sts get-caller-identity | jq -rc '.Arn' ;

build_image: testnumb
	docker build -t "${FULL_IMAGE}" .;
	docker tag "${FULL_IMAGE}" "${IMAGE_NAME}:latest";
	docker tag "${FULL_IMAGE}" "${IMAGE_NAME}:${GIT_BRANCH}";
	docker tag "${FULL_IMAGE}" "${IMAGE_NAME}:${GIT_BRANCH}-g${GIT_VERSION}";


	docker push "${IMAGE_NAME}:${GIT_BRANCH}";
	docker push "${IMAGE_NAME}:${GIT_BRANCH}-g${GIT_VERSION}";
	docker push "${IMAGE_NAME}:latest";
	docker push "${FULL_IMAGE}";

test: build_image
	echo "testing image: "${FULL_IMAGE}" for pulling db's from ${S3_BUCKET}."
	@docker run --rm -it \
	-e S3_BUCKET="ctzn-db-backups" \
  -e AWS_ACCESS_KEY_ID="$(AWS_ACCESS_KEY_ID)" \
  -e AWS_SECRET_ACCESS_KEY="$(AWS_SECRET_ACCESS_KEY)" \
  -e AWS_SESSION_TOKEN="$(AWS_SESSION_TOKEN)" \
	-e ENVIRONMENT="dev" \
		"${FULL_IMAGE}" ;

run:
	docker pull "${FULL_IMAGE}" ;
	docker run --rm -it ${FULL_IMAGE} ;
