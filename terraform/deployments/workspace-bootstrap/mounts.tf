### Databricks DBFS Mounts

# Generate a mountpoint name if one was not provided
# The name would be /mnt/<STORAGE_ACCOUNT_NAME>-<PROJECT_CONTAINER_NAME>
locals {
  PROJECT_MOUNT_POINT = var.PROJECT_MOUNT_POINT == null ? "/mnt/${var.STORAGE_ACCOUNT_NAME}-${var.PROJECT_CONTAINER_NAME}" : basename(var.PROJECT_MOUNT_POINT)
}

# Mount the ADLS Gen2 Project Filesystem using the latest Client Secret of the data pipeline Service Principal
resource "databricks_azure_adls_gen2_mount" "project" {
  container_name         = var.PROJECT_CONTAINER_NAME
  storage_account_name   = var.STORAGE_ACCOUNT_NAME
  mount_name             = local.PROJECT_MOUNT_POINT
  tenant_id              = data.azurerm_client_config.current.tenant_id
  client_id              = data.azuread_service_principal.data_pipeline.application_id
  client_secret_scope    = databricks_secret_scope.main.name
  client_secret_key      = var.SECRET_NAME_CLIENT_SECRET
  initialize_file_system = true
  cluster_id             = databricks_cluster.shared_autoscaling.id
  depends_on             = [databricks_secret.sp_client_secret, databricks_cluster.shared_autoscaling]
}

# Terraform output
output "databricks_mounts" {
  value = {
    project = {
      id         = databricks_azure_adls_gen2_mount.project.id
      mount_name = databricks_azure_adls_gen2_mount.project.mount_name
      details    = databricks_azure_adls_gen2_mount.project
    }
  }
}
