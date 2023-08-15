# Coloured Text 
red:=$(shell tput setaf 1)
yellow:=$(shell tput setaf 3)
reset:=$(shell tput sgr0)

RUNTIME_ENVIRONMENT_OPTS := local container
ifneq ($(filter $(RUNTIME_ENVIRONMENT),$(RUNTIME_ENVIRONMENT_OPTS)),)
    $(info $(yellow)Runtime Environment: $(RUNTIME_ENVIRONMENT)$(reset))
else
    $(error $(red)Variable RUNTIME_ENVIRONMENT is not set to one of the following: $(RUNTIME_ENVIRONMENT_OPTS)$(reset))
endif

TEMPLATE_NAME_OPTS := standard oidc
ifneq ($(filter $(TEMPLATE_NAME),$(TEMPLATE_NAME_OPTS)),)
    $(info $(yellow)Runtime Environment: $(TEMPLATE_NAME)$(reset))
else
    $(error $(red)Variable TEMPLATE_NAME is not set to one of the following: $(TEMPLATE_NAME_OPTS)$(reset))
endif

DOCKER_COMPOSE_PATH=docker/docker-compose.yml
TERRAFORM_PATH=projects/${PROJECT_NAME}
TEMPLATE_PATH=templates/${TEMPLATE_NAME}
IMAGE_NAME=azureterraform
CONTAINER_NAME=azure-terraform

TERRAFORM_VARS := ARM_CLIENT_ID ARM_CLIENT_SECRET ARM_TENANT_ID ARM_SUBSCRIPTION_ID ARM_ACCESS_KEY

.PHONY: help
help:					## Displays the help
	@printf "\nUsage : make <command> \n\nThe following commands are available: \n\n"
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@printf "\n"

.PHONY: pre-commit
pre-commit:				## Run pre-commit checks
	pre-commit run --all-files

.PHONY: docker-build
docker-build:					## Builds the docker image
	docker-compose -f $(DOCKER_COMPOSE_PATH) build $(CONTAINER_NAME)

.PHONY: docker-start
docker-start: 					## Runs the docker container
	docker-compose -f $(DOCKER_COMPOSE_PATH) up -d $(CONTAINER_NAME)

.PHONY: docker-stop
docker-stop:					## Stops and Remove the docker container
	@docker ps -q --filter "name=$(CONTAINER_NAME)" | grep -q .;\
	if [ $$? -eq 0 ]; \
    then \
        docker-compose -f $(DOCKER_COMPOSE_PATH) stop $(CONTAINER_NAME); \
        docker rm $(CONTAINER_NAME); \
    fi

.PHONY: docker-rmi
docker-rmi: docker-stop					## Remove docker image
	docker rmi $(IMAGE_NAME)

.PHONY: docker-restart
docker-restart: docker-stop docker-start			## Restart the docker container

.PHONY: docker-exec
docker-exec: docker-start				## Runs the docker container
	docker exec -it $(CONTAINER_NAME) bash

.PHONY: cloud-auth
cloud-auth: 			## Azure Login
ifeq ($(strip $(RUNTIME_ENVIRONMENT)),local)
ifeq ($(ARM_CLIENT_SECRET),)
	az login --tenant ${ARM_TENANT_ID}; \
    az account set -s ${ARM_SUBSCRIPTION_ID}
else
	az login --service-principal \
        --username=${ARM_CLIENT_ID} \
        --password=${ARM_CLIENT_SECRET} \
        --tenant ${ARM_TENANT_ID}; \
    az account set -s ${ARM_SUBSCRIPTION_ID}
endif
else ifeq ($(strip $(RUNTIME_ENVIRONMENT)),container)
	make docker-restart
ifeq ($(ARM_CLIENT_SECRET),)
	docker exec -it $(CONTAINER_NAME) az login --tenant ${ARM_TENANT_ID} && az account set -s ${ARM_SUBSCRIPTION_ID}
else
	docker exec -it $(CONTAINER_NAME) az login --service-principal --username=${ARM_CLIENT_ID} --password=${ARM_CLIENT_SECRET} --tenant ${ARM_TENANT_ID} && az account set -s ${ARM_SUBSCRIPTION_ID}
endif
endif

.PHONY: project-init
project-init:			## Create Project
	mkdir -p ${TERRAFORM_PATH}
	cp -R -p ${TEMPLATE_PATH}/* ${TERRAFORM_PATH}

.PHONY: terra-init
terra-init: cloud-auth		## Initialises Terraform
ifeq ($(strip $(RUNTIME_ENVIRONMENT)),local)
	terraform -chdir=$(TERRAFORM_PATH) init
	terraform -chdir=$(TERRAFORM_PATH) fmt --recursive
else ifeq ($(strip $(RUNTIME_ENVIRONMENT)),container)
	docker exec -it $(CONTAINER_NAME) terraform -chdir=$(TERRAFORM_PATH) init
endif

.PHONY: terra-plan
terra-plan: terra-init			## Plans Terraform
ifeq ($(strip $(RUNTIME_ENVIRONMENT)),local)
	terraform -chdir=$(TERRAFORM_PATH) validate
	terraform -chdir=$(TERRAFORM_PATH) plan -out=plan/tfplan.binary -var-file vars.tfvars
else ifeq ($(strip $(RUNTIME_ENVIRONMENT)),container)
	docker exec -it $(CONTAINER_NAME) terraform -chdir=$(TERRAFORM_PATH) validate
	docker exec -it $(CONTAINER_NAME) terraform -chdir=$(TERRAFORM_PATH) plan -out=plan/tfplan.binary -var-file vars.tfvars
endif

.PHONY: terra-apply
terra-apply: terra-plan			## Apply Terraform
ifeq ($(strip $(RUNTIME_ENVIRONMENT)),local)
	terraform -chdir=$(TERRAFORM_PATH) apply plan/tfplan.binary
else ifeq ($(strip $(RUNTIME_ENVIRONMENT)),container)
	docker exec -it $(CONTAINER_NAME) terraform -chdir=$(TERRAFORM_PATH) apply plan/tfplan.binary
endif

.PHONY: terra-destroy
terra-destroy: 			## Destroy Resources create by Terraform
ifeq ($(strip $(RUNTIME_ENVIRONMENT)),local)
	sh ./scripts/destroy_resources.sh
else ifeq ($(strip $(RUNTIME_ENVIRONMENT)),container)
	docker exec -it $(CONTAINER_NAME) sh ./$(CLOUD)/destroy_resources.sh
endif