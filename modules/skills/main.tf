# ==========================================
# Skills Module Main Resource File
# Iterates through the `var.skills` map and creates Routing Skills.
# ==========================================

resource "genesyscloud_routing_skill" "skills" {
  for_each = var.skills
  name     = each.value.name
}
