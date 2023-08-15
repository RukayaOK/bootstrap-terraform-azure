# ASSIGN SERVICE PRINCIPAL RBAC PERMISSIONS
resource "azurerm_role_assignment" "any_role_assignment" {
  for_each             = var.service_principal_rbac_assignment
  scope                = each.key
  role_definition_name = each.value
  principal_id         = try(azuread_service_principal.main.id, var.azuread_directory_roles_object_id)
}

# ASSIGN AZURE AD ROLES
resource "azuread_directory_role" "main" {
  for_each     = toset(var.azuread_directory_roles)
  display_name = each.value
}

resource "azuread_directory_role_assignment" "main" {
  for_each            = azuread_directory_role.main
  role_id             = each.value.id
  principal_object_id = try(azuread_service_principal.main.id, var.azuread_directory_roles_object_id)

  lifecycle {
    ignore_changes = [
      role_id
    ]
  }
}


# ASSIGN SERVICE PRINCIPAL GRAPH API PERMISSIONS
resource "null_resource" "graph_api_permissions" {

  for_each = toset(var.graph_api_permissions)

  triggers = {
    service_principal_id  = try(azuread_service_principal.main.id, var.azuread_directory_roles_object_id)
    graph_permission_name = each.value
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/graph_api_permissions.sh"
    interpreter = ["/bin/bash"]

    environment = {
      ACTION               = "create"
      SERVICE_PRINCIPAL_ID = self.triggers.service_principal_id
      PERMISSION_NAME      = self.triggers.graph_permission_name
    }
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "${path.module}/scripts/graph_api_permissions.sh"
    interpreter = ["/bin/bash"]

    environment = {
      ACTION               = "destroy"
      SERVICE_PRINCIPAL_ID = self.triggers.service_principal_id
      PERMISSION_NAME      = self.triggers.graph_permission_name
    }
  }


  depends_on = [azuread_service_principal.main]
}
