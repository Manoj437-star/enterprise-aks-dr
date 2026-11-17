output "workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.law.id
}

output "workspace_name" {
  description = "Log Analytics Workspace Name"
  value       = azurerm_log_analytics_workspace.law.name
}

output "action_group_id" {
  description = "Action Group ID"
  value       = azurerm_monitor_action_group.ag.id
}
