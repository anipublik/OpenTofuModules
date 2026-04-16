resource "google_access_context_manager_access_policy" "this" {
  count = lookup(local.config.vpc_sc, "create_access_policy", false) ? 1 : 0

  parent = "organizations/${local.config.gcp.organization_id}"
  title  = local.policy_name
}

resource "google_access_context_manager_access_level" "this" {
  for_each = { for idx, level in lookup(local.config.vpc_sc, "access_levels", []) : idx => level }

  parent = "accessPolicies/${lookup(local.config.vpc_sc, "create_access_policy", false) ? google_access_context_manager_access_policy.this[0].name : local.config.vpc_sc.access_policy_name}"
  name   = "accessPolicies/${lookup(local.config.vpc_sc, "create_access_policy", false) ? google_access_context_manager_access_policy.this[0].name : local.config.vpc_sc.access_policy_name}/accessLevels/${each.value.name}"
  title  = each.value.name

  basic {
    dynamic "conditions" {
      for_each = lookup(each.value, "conditions", [])
      content {
        ip_subnetworks         = lookup(conditions.value, "ip_subnetworks", null)
        required_access_levels = lookup(conditions.value, "required_access_levels", null)
        members                = lookup(conditions.value, "members", null)
        negate                 = lookup(conditions.value, "negate", false)
        regions                = lookup(conditions.value, "regions", null)

        dynamic "device_policy" {
          for_each = lookup(conditions.value, "device_policy", null) != null ? [1] : []
          content {
            require_screen_lock              = lookup(conditions.value.device_policy, "require_screen_lock", false)
            require_admin_approval           = lookup(conditions.value.device_policy, "require_admin_approval", false)
            require_corp_owned               = lookup(conditions.value.device_policy, "require_corp_owned", false)
            allowed_encryption_statuses      = lookup(conditions.value.device_policy, "allowed_encryption_statuses", null)
            allowed_device_management_levels = lookup(conditions.value.device_policy, "allowed_device_management_levels", null)
          }
        }
      }
    }
  }
}

resource "google_access_context_manager_service_perimeter" "this" {
  for_each = { for idx, perimeter in lookup(local.config.vpc_sc, "service_perimeters", []) : idx => perimeter }

  parent = "accessPolicies/${lookup(local.config.vpc_sc, "create_access_policy", false) ? google_access_context_manager_access_policy.this[0].name : local.config.vpc_sc.access_policy_name}"
  name   = "accessPolicies/${lookup(local.config.vpc_sc, "create_access_policy", false) ? google_access_context_manager_access_policy.this[0].name : local.config.vpc_sc.access_policy_name}/servicePerimeters/${each.value.name}"
  title  = each.value.name

  status {
    resources           = lookup(each.value, "resources", [])
    restricted_services = lookup(each.value, "restricted_services", [])
    access_levels       = [for level_idx in lookup(each.value, "access_level_indices", []) : google_access_context_manager_access_level.this[level_idx].name]

    dynamic "vpc_accessible_services" {
      for_each = lookup(each.value, "vpc_accessible_services", null) != null ? [1] : []
      content {
        enable_restriction = lookup(each.value.vpc_accessible_services, "enable_restriction", true)
        allowed_services   = lookup(each.value.vpc_accessible_services, "allowed_services", [])
      }
    }

    dynamic "ingress_policies" {
      for_each = lookup(each.value, "ingress_policies", [])
      content {
        ingress_from {
          sources {
            access_level = lookup(ingress_policies.value.ingress_from.sources, "access_level", null)
            resource     = lookup(ingress_policies.value.ingress_from.sources, "resource", null)
          }
          identity_type = lookup(ingress_policies.value.ingress_from, "identity_type", null)
          identities    = lookup(ingress_policies.value.ingress_from, "identities", null)
        }

        ingress_to {
          resources = lookup(ingress_policies.value.ingress_to, "resources", ["*"])
          operations {
            service_name = ingress_policies.value.ingress_to.operations.service_name
            method_selectors {
              method = lookup(ingress_policies.value.ingress_to.operations.method_selectors, "method", "*")
            }
          }
        }
      }
    }

    dynamic "egress_policies" {
      for_each = lookup(each.value, "egress_policies", [])
      content {
        egress_from {
          identity_type = lookup(egress_policies.value.egress_from, "identity_type", null)
          identities    = lookup(egress_policies.value.egress_from, "identities", null)
        }

        egress_to {
          resources = lookup(egress_policies.value.egress_to, "resources", ["*"])
          operations {
            service_name = egress_policies.value.egress_to.operations.service_name
            method_selectors {
              method = lookup(egress_policies.value.egress_to.operations.method_selectors, "method", "*")
            }
          }
        }
      }
    }
  }

  perimeter_type = lookup(each.value, "perimeter_type", "PERIMETER_TYPE_REGULAR")
}
