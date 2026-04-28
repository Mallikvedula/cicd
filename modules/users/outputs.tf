# ==========================================
# Users Module Outputs
# Exposes the dynamically generated IDs and properties of the created users back to the root module.
# ==========================================

output "user_details" {
  description = "A map of user names, emails, and their generated Genesys Cloud IDs"
  
  # Loops through all created users and constructs an object mapping their key to their details
  value = {
    for k, v in genesyscloud_user.users : k => {
      name  = v.name
      email = v.email
      id    = v.id
    }
  }
}

