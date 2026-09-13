resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${var.app_name}"
  location                   = var.location
  resource_group_name        = data.azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
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

      # NOTE: SQLite lives on the container's local ephemeral disk here, not on
      # a network share. Azure Files (SMB) does not reliably support the file
      # locking SQLite needs for transactions ("database is locked" errors).
      # Trade-off: data does NOT persist across restarts/redeploys/scaling
      # events. Revisit with a managed database (e.g. PostgreSQL) if
      # persistence across restarts becomes a requirement.
      env {
        name  = "ConnectionStrings__DefaultConnection"
        value = "Data Source=/app/data/todos.db"
      }
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
