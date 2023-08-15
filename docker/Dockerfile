ARG ANSIBLE_VERSION=3.16

FROM alpine:${ANSIBLE_VERSION} as base 

#########################
####### TERRAFORM #######
#########################
# Set Terraform Variables
ENV TERRAFORM_VERSION=1.2.1 \
    TERRAFORM_OSNAME=linux \
    TERRAFORM_OSARCH=amd64 \
    TERRAFORM_DEST=/usr/local/bin
ENV TERRAFORM_ZIPFILE=terraform_${TERRAFORM_VERSION}_${TERRAFORM_OSNAME}_${TERRAFORM_OSARCH}.zip

# Download Terraform 
RUN wget -qP ${TERRAFORM_DEST}/ https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_ZIPFILE}

# Unzip Terraform and Remove zip file
RUN unzip ${TERRAFORM_DEST}/${TERRAFORM_ZIPFILE} -d ${TERRAFORM_DEST} \
    && rm ${TERRAFORM_DEST}/${TERRAFORM_ZIPFILE}


######################
####### TFLINT #######
######################
# Set Terraform Variables
ENV TFLINT_VERSION=0.43.0 \
    TFLINT_OSNAME=linux \
    TFLINT_OSARCH=amd64 \
    TFLINT_DEST=/usr/local/bin
ENV TFLINT_ZIPFILE=tflint_${TFLINT_OSNAME}_${TFLINT_OSARCH}.zip

RUN wget -qP ${TFLINT_DEST}/ https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/${TFLINT_ZIPFILE}

# Unzip Terraform and Remove zip file
RUN unzip ${TFLINT_DEST}/${TFLINT_ZIPFILE} -d ${TFLINT_DEST} \
    && rm ${TFLINT_DEST}/${TFLINT_ZIPFILE}


###############################
####### ALPINE PACKAGES #######
###############################
# Download Alpine Packages and Remove apk cache
RUN apk add --update py3-pip python3-dev gcc libc-dev libffi-dev \
    && apk add bash openssl ca-certificates jq \
    && rm -rf /var/cache/apk/* 

#######################
####### CHECKOV #######
#######################
# Set Checkov Variables
ENV CHECKOV_VERSION=2.1.242
# Install Checkov
RUN pip3 install --no-cache-dir -U checkov==$CHECKOV_VERSION

################################
####### PROJECT SPECIFIC #######
################################
WORKDIR /src
COPY . .

ENV USER_ID=65535
ENV GROUP_ID=65535
ENV USER_NAME=non-root-user
ENV GROUP_NAME=non-root-group

RUN addgroup -g $GROUP_ID $GROUP_NAME && \
    adduser --shell /sbin/nologin --disabled-password \
    --no-create-home --uid $USER_ID --ingroup $GROUP_NAME $USER_NAME && \
    chown -R $USER_NAME:$GROUP_NAME .

###########################
####### AZURE LAYER #######
###########################
FROM base as azure

# Set Azure CLI Variables
ENV AZURE_CLI_VERSION=2.43.0
# Install Azure CLI 
RUN pip3 install --no-cache-dir -U azure-cli==$AZURE_CLI_VERSION

#Not working
#USER $USER_NAME 

CMD ["bash"]