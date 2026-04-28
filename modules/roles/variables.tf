# ==========================================
# Roles Module Variables
# Defines the exact object structure required to build a Genesys Cloud Role.
# ==========================================

variable "roles" {
  description = "A map of custom roles to create"
  type = map(object({
    name        = string       # Internal name
    description = string       # Description of what the role can do
    permissions = list(string) # The array of permission scopes to grant
  }))
  default = {} # Default to empty if nothing is passed
}

