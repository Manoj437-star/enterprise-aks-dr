resource "azurerm_log_analytics_workspace" "law" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "ag" {
  name                = "ag-aks-dr-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "dr-alerts"

  email_receiver {
    name          = "admin-email"
    email_address = var.alert_email
  }

  tags = var.tags
}

# Alert 1: AKS Node NotReady for > 2 minutes
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "node_not_ready" {
  name                 = "alert-aks-node-not-ready"
  resource_group_name  = var.resource_group_name
  location             = var.location
  scopes               = [azurerm_log_analytics_workspace.law.id]
  description          = "Triggers when any AKS node is in NotReady state for more than 2 minutes"
  severity             = 1
  evaluation_frequency = "PT1M"
  window_duration      = "PT5M"

  criteria {
    query                   = <<-QUERY
      KubeNodeInventory
      | where Status == "NotReady"
      | summarize AggregatedValue = count() by Node, bin(TimeGenerated, 1m)
    QUERY
    time_aggregation_method = "Count"
    threshold               = 2
    operator                = "GreaterThan"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.ag.id]
  }

  tags = var.tags
}

# Alert 2: Pod CrashLoop condition > 3 restarts
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "pod_crashloop" {
  name                 = "alert-aks-pod-crashloop"
  resource_group_name  = var.resource_group_name
  location             = var.location
  scopes               = [azurerm_log_analytics_workspace.law.id]
  description          = "Triggers when any pod restarts more than 3 times within a 5 minute window"
  severity             = 2
  evaluation_frequency = "PT1M"
  window_duration      = "PT5M"

  criteria {
    query                   = <<-QUERY
      KubePodInventory
      | where PodRestartCount > 3
      | summarize AggregatedValue = max(PodRestartCount) by Name, Namespace, bin(TimeGenerated, 5m)
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.ag.id]
  }

  tags = var.tags
}

# Alert 3: PVC utilization > 80%
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "pvc_utilization_high" {
  name                 = "alert-aks-pvc-high-usage"
  resource_group_name  = var.resource_group_name
  location             = var.location
  scopes               = [azurerm_log_analytics_workspace.law.id]
  description          = "Triggers when PersistentVolumeClaim storage utilization exceeds 80%"
  severity             = 2
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"

  criteria {
    query                   = <<-QUERY
      InsightsMetrics
      | where Namespace == "container.azm.ms/disk" and Name == "used_percent"
      | where Val > 80
      | summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 5m)
    QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThanOrEqual"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.ag.id]
  }

  tags = var.tags
}
