# ==========================================
# Divisions Module Main Resource File
# Iterates through the `var.divisions` map and creates Divisions in Genesys Cloud.
# ==========================================

resource "genesyscloud_auth_division" "divisions" {
  for_each    = var.divisions
  
  name        = each.value.name
  description = each.value.description
  home        = each.value.home
}
