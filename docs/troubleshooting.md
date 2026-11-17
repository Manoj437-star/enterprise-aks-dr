# Troubleshooting Log – Enterprise AKS Disaster Recovery POC

## Incident Log & Resolution Record

---

### Incident 001: ReadOnlyDisabledSubscription during Terraform Apply
- **Date/Time:** 2026-11-17 16:23:42 IST
- **Component:** Terraform Primary Region Deployment (`azurerm_resource_group.primary`)
- **Error Code:** `409 Conflict - ReadOnlyDisabledSubscription`
- **Error Message:**
  ```text
  ReadOnlyDisabledSubscription: The subscription 'a22e5b40-a701-4b0e-b937-b43ed360039b' is disabled and therefore marked as read only. You cannot perform any write actions on this subscription until it is re-enabled.
  ```

#### Root Cause Analysis (RCA)
- The subscription `Azure subscription 1` (`a22e5b40-a701-4b0e-b937-b43ed360039b`) is an Azure Free Trial (`FreeTrial_2014-09-01`) with policy `spendingLimit = "On"`.
- When the free trial credit cap is reached or the initial trial window lapses, Azure Resource Manager (ARM) places the subscription into a `Disabled` state.
- In this state, existing assets remain visible in read-only mode, but ARM blocks any write API calls (`PUT`, `POST`, `DELETE`).

#### Resolution Steps
1. Navigate to the [Azure Portal Subscriptions Blade](https://portal.azure.com/#view/Microsoft_Azure_Billing/SubscriptionsBlade).
2. Select subscription `Azure subscription 1` (`a22e5b40-a701-4b0e-b937-b43ed360039b`).
3. Click **Upgrade subscription** or **Remove spending limit** to convert to Pay-As-You-Go.
4. Once Azure marks the subscription as `Enabled`, re-run:
   ```bash
   cd d:\DevOps\enterprise-aks-dr\terraform\primary
   terraform apply "tfplan"
   ```
5. Alternatively, if using a different active subscription:
   ```bash
   az account set --subscription <ACTIVE_SUBSCRIPTION_ID>
   ```

---

### Incident 002: Provider v4 Schema Compatibility in Front Door and Traffic Manager
- **Date/Time:** 2026-11-17 15:29:00 IST
- **Component:** `terraform/modules/frontdoor` and `terraform/modules/traffic-manager`
- **Error Description:**
  - `azurerm_cdn_frontdoor_origin`: Missing required argument `certificate_name_check_enabled`.
  - `azurerm_traffic_manager_external_endpoint`: `endpoint_status` argument deprecated in favor of `enabled = true`.
- **Resolution:**
  - Added `certificate_name_check_enabled = false` to both Front Door origins.
  - Replaced `endpoint_status = "Enabled"` with `enabled = true` for Traffic Manager endpoints.
  - Verified with `terraform validate`: returned `Success! The configuration is valid.`
