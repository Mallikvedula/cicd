# ==========================================
# Users Module Main Resource File
# Iterates through the `var.users` map and creates user accounts in Genesys Cloud.
# ==========================================

resource "genesyscloud_user" "users" {
  # The for_each loop iterates over the `users` map from the root variables
  for_each = var.users
  
  name  = each.value.name  # The full name of the user
  email = each.value.email # The primary email (used for login)
  state = each.value.state # Is the user active or inactive?

  dynamic "routing_skills" {
    for_each = each.value.routing_skills != null ? each.value.routing_skills : []
    content {
      skill_id    = routing_skills.value.skill_id != null ? routing_skills.value.skill_id : var.created_skills[routing_skills.value.skill_name].id
      proficiency = routing_skills.value.proficiency
    }
  }
}

