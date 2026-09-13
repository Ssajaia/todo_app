resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${var.app_name}"
  location                   = data.azurerm_resource_group.main.location
  resource_group_name        = data.azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}

# Mount the Azure Files share into the Container Apps Environment so the
# container can write its SQLite database to a persistent location.
resource "azurerm_container_app_environment_storage" "todo_data" {
  name                         = "todo-data"
  container_app_environment_id = azurerm_container_app_environment.main.id
  account_name                 = azurerm_storage_account.data.name
  share_name                   = azurerm_storage_share.todo_data.name
  access_key                   = azurerm_storage_account.data.primary_access_key
  access_mode                  = "ReadWrite"
}

resource "azurerm_container_app" "main" {
  name                         = var.app_name
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = data.azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "todo-app"
      image  = var.container_image
      cpu    = var.container_cpu
      memory = var.container_memory

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Production"
      }

      env {
        name  = "ASPNETCORE_URLS"
        value = "http://+:8080"
      }

      env {
        name  = "ConnectionStrings__DefaultConnection"
        value = "Data Source=/app/data/todos.db"
      }

      volume_mounts {
        name = "todo-data"
        path = "/app/data"
      }
    }

    volume {
      name         = "todo-data"
      storage_type = "AzureFile"
      storage_name = azurerm_container_app_environment_storage.todo_data.name
    }

    min_replicas = 1
    max_replicas = 1
  }

  ingress {
    external_enabled = true
    target_port      = 8080

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
