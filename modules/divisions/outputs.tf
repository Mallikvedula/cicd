# ==========================================
# Divisions Module Outputs
# Exposes the created divisions to other modules.
# ==========================================

output "division_details" {
  description = "A map of division names and their generated Genesys Cloud IDs"
  
  value = {
    for k, v in genesyscloud_auth_division.divisions : k => {
      id   = v.id
      name = v.name
    }
  }
}
