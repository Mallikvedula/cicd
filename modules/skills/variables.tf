# ==========================================
# Skills Module Variables
# ==========================================

variable "skills" {
  description = "A map of routing skills to create"
  type = map(object({
    name = string # (Required) The display name of the skill
  }))
  default = {}
}
