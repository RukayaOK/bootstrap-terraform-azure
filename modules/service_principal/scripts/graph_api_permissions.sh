#!/bin/bash

function az_login () {
    if az account show; then 
        export LOGGED_IN=true
    else 
        # LOGIN TO AZURE
        az login --service-principal \
            --username=${ARM_CLIENT_ID} \
            --password=${ARM_CLIENT_SECRET} \
            --tenant=${ARM_TENANT_ID} >/dev/null 2>&1
    fi 
}

function az_logout() {
    if [[ ${LOGGED_IN} == true ]]; then 
        pass 
    else 
        az logout || true
    fi
}

function get_details {
    # GET RESOURCE ID - e.g ID for Microsoft Graph
    GRAPH_API_PERMISSION_ID=$(az ad sp list \
        --query "[?appDisplayName=='Microsoft Graph'].{appId:appId}[0]" \
        --all --only-show-errors | jq -r .appId) && echo "GRAPH_API_PERMISSION_ID: ${GRAPH_API_PERMISSION_ID}"

    RESOURCE_ID=$(az ad sp show --id "${GRAPH_API_PERMISSION_ID}" --query "id" -o tsv) && echo "RESOURCE_ID: ${RESOURCE_ID}"

    # GET APP ROLE ID - e.g. ID for Group.ReadWrite.All
    API_PERMISSION_ID=$(az ad sp show \
        --id "${GRAPH_API_PERMISSION_ID}" \
        --query "appRoles[?value=='${PERMISSION_NAME}'].id" \
        --output tsv \
        --only-show-errors) && echo "API_PERMISSION_ID: ${API_PERMISSION_ID}" && echo "API_PERMISSION_ID: ${API_PERMISSION_ID}"

    # GET URI CONSTRUCTORS
    MICROSOFT_GRAPH_ENDPOINT=$(az cloud show | jq -r ".endpoints.microsoftGraphResourceId") && echo "MICROSOFT_GRAPH_ENDPOINT: ${MICROSOFT_GRAPH_ENDPOINT}"
    LIST_URI=$(echo "${MICROSOFT_GRAPH_ENDPOINT}v1.0/servicePrincipals/${SERVICE_PRINCIPAL_ID}/appRoleAssignments") && echo "LIST_URI: ${LIST_URI}"

    # CHECK IF API PERMISSION EXISTS
    EXISTING_APP_PERMISSION_ID=$(az rest --method GET --uri ${LIST_URI} \
        --query "value[?appRoleId=='${API_PERMISSION_ID}' && principalId=='${SERVICE_PRINCIPAL_ID}' && resourceId=='${RESOURCE_ID}'].id" -o tsv) &&
        echo "EXISTING_APP_PERMISSION_ID: ${EXISTING_APP_PERMISSION_ID}"

}

function create() {

    get_details

    if [ -z ${EXISTING_APP_PERMISSION_ID} ]; then
        ADD_URI=$(echo "${MICROSOFT_GRAPH_ENDPOINT}v1.0/servicePrincipals/${SERVICE_PRINCIPAL_ID}/appRoleAssignments") && echo "ADD_URI: ${ADD_URI}"

        JSON=$(jq -n \
            --arg principalId "${SERVICE_PRINCIPAL_ID}" \
            --arg resourceId "${RESOURCE_ID}" \
            --arg appRoleId "${API_PERMISSION_ID}" \
            '{principalId: $principalId, resourceId: $resourceId, appRoleId: $appRoleId}') && echo "JSON: $JSON"

        az rest --method POST --uri $ADD_URI --header Content-Type=application/json --body "$JSON"
    else
        echo "API permission already granted."
    fi

}

function destroy() {

    get_details

    if [ ! -z ${EXISTING_APP_PERMISSION_ID} ]; then
        REMOVE_URI=$(echo "${MICROSOFT_GRAPH_ENDPOINT}v1.0/servicePrincipals/${SERVICE_PRINCIPAL_ID}/appRoleAssignments/${EXISTING_APP_PERMISSION_ID}") && echo "REMOVE_URI: ${REMOVE_URI}"
        az rest --method DELETE --uri ${REMOVE_URI}
    else
        echo "API permission not granted."
    fi

}

if [ "${ACTION}" == "create" ]; then
    az_login
    create
elif [ "${ACTION}" == "destroy" ]; then
    az_login
    destroy
fi
