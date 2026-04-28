# ==========================================
# Divisions Module Variables
# ==========================================

variable "divisions" {
  description = "A map of divisions to create"
  type = map(object({
    name        = string             # (Required) The display name of the division
    description = optional(string)   # (Optional) Description of the division
    home        = optional(bool, false) # (Optional) Whether this should be set as the home division
  }))
  default = {}
}
