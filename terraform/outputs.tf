output "container_app_url" {
  description = "Public URL of the deployed Todo app."
  value       = "https://${azurerm_container_app.main.ingress[0].fqdn}"
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID (for querying logs/metrics)."
  value       = azurerm_log_analytics_workspace.main.id
}
