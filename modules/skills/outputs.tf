# ==========================================
# Skills Module Outputs
# Exposes the created routing skills to other modules.
# ==========================================

output "skill_details" {
  description = "A map of skill names and their generated Genesys Cloud IDs"
  
  value = {
    for k, v in genesyscloud_routing_skill.skills : k => {
      id   = v.id
      name = v.name
    }
  }
}
