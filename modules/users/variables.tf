# ==========================================
# Users Module Variables
# Defines the expected properties for creating a Genesys Cloud User.
# Includes built-in Terraform validation functions to prevent common errors.
# ==========================================

variable "users" {
  description = "A map of users to create"
  type = map(object({
    name           = string
    email          = string
    state          = string
    routing_skills = optional(list(object({
      skill_id    = optional(string)
      skill_name  = optional(string)
      proficiency = number
    })))
  }))
  default = {}

  # Validation Block 1: State
  # Ensures the state string is either strictly 'active' or 'inactive'
  validation {
    condition     = alltrue([for u in var.users : contains(["active", "inactive"], u.state)])
    error_message = "User state must be either 'active' or 'inactive'."
  }

  # Validation Block 2: Email Regex
  # Uses a regular expression to verify the email is properly structured (e.g., name@domain.com)
  validation {
    condition     = alltrue([for u in var.users : can(regex("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9-]+)*$", u.email))])
    error_message = "All user emails must be in a valid email format."
  }
}

# ==========================================
# Dynamic Cross-Module Dependency mapping
# ==========================================
variable "created_skills" {
  description = "Map of skill names to their generated IDs from the skills module"
  type        = map(object({
    id   = string
    name = string
  }))
  default     = {}
}

