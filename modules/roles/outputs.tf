# ==========================================
# Roles Module Outputs
# Exposes the dynamically generated IDs and properties of the created roles back to the root module.
# ==========================================

output "role_details" {
  description = "A map of role names and their generated Genesys Cloud IDs"
  
  # Loops through all created roles and constructs an object mapping their key to their details
  value = {
    for k, v in genesyscloud_auth_role.custom_roles : k => {
      name = v.name
      id   = v.id
    }
  }
}

