# ==========================================
# Roles Module Main Resource File
# Iterates through the `var.roles` map and creates custom Authorization Roles in Genesys Cloud.
# ==========================================

resource "genesyscloud_auth_role" "custom_roles" {
  # The for_each loop iterates over the `roles` map from root variables
  for_each    = var.roles
  
  name        = each.value.name        # The display name of the role
  description = each.value.description # What this role should be used for
  permissions = each.value.permissions # A list of exact API permission strings (e.g., "routing:queue:view")
}

