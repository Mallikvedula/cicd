# ==========================================
# Root Variables Definition
# This file defines the expected input structure for the entire project.
# These variables will be populated by `terraform.tfvars`.
# ==========================================

# 1. Divisions Variable
# Defines the expected structure for creating Genesys Cloud divisions
variable "divisions" {
  description = "Divisions to be passed to the divisions module"
  type = map(object({
    name        = string                # Division display name
    description = optional(string)      # Purpose of the division
    home        = optional(bool, false) # Whether this is the home division
  }))
  default = {}
}

# 2. Skills Variable
variable "skills" {
  description = "Skills to be passed to the skills module"
  type = map(object({
    name = string # Skill display name
  }))
  default = {}
}

# 3. Queues Variable
# This is a map of objects. Each "key" in the map represents a unique queue to create.
variable "queues" {
  description = "A complex object containing all configuration options for Genesys Cloud Queues"
  type = map(object({
    name                    = string           # (Required) The display name of the queue in Genesys Cloud
    description             = optional(string) # (Optional) Description of the queue
    division_id             = optional(string) # (Optional) The division to place the queue in
    division_name           = optional(string) # (Optional) Dynamic name lookup mapping
    acw_wrapup_prompt       = optional(string) # (Optional) After Call Work (ACW) prompt type (e.g., MANDATORY_TIMEOUT)
    acw_timeout_ms          = optional(number) # (Optional) How long ACW lasts in milliseconds
    skill_evaluation_method = optional(string) # (Optional) How routing evaluates agent skills (e.g., BEST, ALL)

    # Flow Lookup Fields
    queue_flow_id   = optional(string)                # (Optional) Direct ID of the In-Queue Call Flow
    queue_flow_name = optional(string)                # (Optional) Human-readable name of the Flow for automated lookup
    queue_flow_type = optional(string, "inqueuecall") # Defaulted to "inqueuecall" for Routing Queues

    # Prompt Lookup Fields
    whisper_prompt_id   = optional(string) # (Optional) Direct ID of the Whisper Prompt played to agents
    whisper_prompt_name = optional(string) # (Optional) Human-readable name of the Whisper Prompt

    # Queue Settings
    auto_answer_only         = optional(bool)   # (Optional) If true, interactions auto-answer for agents
    enable_transcription     = optional(bool)   # (Optional) If true, Voice transcription is enabled
    enable_audio_monitoring  = optional(bool)   # (Optional) If true, supervisors can monitor calls
    enable_manual_assignment = optional(bool)   # (Optional) If true, agents can manually grab interactions
    calling_party_name       = optional(string) # (Optional) Caller ID name when making outbound calls on behalf of queue

    # Group Assignments
    groups      = optional(list(string)) # (Optional) List of Direct Group IDs for standard routing
    group_names = optional(list(string)) # (Optional) List of Group Names for automated lookup

    wrapup_codes       = optional(list(string)) # (Optional) List of Wrapup Code IDs allowed on this queue
    default_script_ids = optional(map(string))  # (Optional) Scripts bound to different media types

    # Outbound Email Configuration
    outbound_email_address = optional(object({
      domain_id = string
      route_id  = string
    }))

    # Media Settings (Service Level Targets)
    media_settings_call = optional(object({
      alerting_timeout_sec      = optional(number) # How many seconds before an interaction alerts the next agent
      service_level_percentage  = optional(number) # Target SLA percentage (e.g., 0.8 for 80%)
      service_level_duration_ms = optional(number) # Target SLA duration in MS (e.g., 20000 for 20s)
    }))

    # Routing Rules
    routing_rules = optional(list(object({
      operator     = string # e.g., MEETS_THRESHOLD
      threshold    = number
      wait_seconds = number # How long to wait before this rule expands
    })))

    # Bullseye Routing (Expanding rings of agents)
    bullseye_rings = optional(list(object({
      expansion_timeout_seconds = number # Time before expanding to the next ring
      skills_to_remove          = optional(list(string))
      member_groups = optional(list(object({
        member_group_id   = optional(string) # Direct ID of the group for this ring
        member_group_name = optional(string) # Name of the group for automated lookup
        member_group_type = string           # e.g., "GROUP" or "SKILLGROUP"
      })))
    })))

    # Conditional Group Activation (CGA) - Dynamic overflow
    conditional_group_activation = optional(object({
      pilot_rule = optional(object({ # The primary condition that triggers rules evaluating
        condition_expression = string
        conditions = list(object({
          simple_metric = object({
            metric   = string # e.g., "EstimatedWaitTime"
            queue_id = optional(string)
          })
          operator = string # e.g., "GreaterThan"
          value    = number # Threshold value
        }))
      }))
      rules = optional(list(object({ # Specific rules that activate specific groups
        condition_expression = string
        conditions = list(object({
          simple_metric = object({
            metric   = string # e.g., "IdleAgentCount"
            queue_id = optional(string)
          })
          operator = string # e.g., "LessThan"
          value    = number
        }))
        groups = list(object({ # Groups to activate if condition met
          member_group_id   = optional(string)
          member_group_name = optional(string)
          member_group_type = string
        }))
      })))
    }))

    # Direct Member Assignment (Agents added directly to queue)
    members = optional(list(object({
      user_id   = optional(string) # (Optional) Direct ID of the user
      user_name = optional(string) # (Optional) Dynamic name lookup mapping
      ring_num  = number           # Which bullseye ring they belong to (1 for standard routing)
    })))
  }))
}


# 4. Users Variable
# Defines the expected structure for creating Genesys Cloud users
variable "users" {
  description = "Users to be passed to the users module"
  type = map(object({
    name  = string # Display name
    email = string # Primary email address (must be unique)
    state = string # "active", "inactive", or "deleted"
    routing_skills = optional(list(object({
      skill_id    = optional(string) # Explicit skill ID
      skill_name  = optional(string) # Dynamic lookup name
      proficiency = number
    })))
  }))
}

# 5. Roles Variable
# Defines the expected structure for creating Authorization Roles
variable "roles" {
  description = "Roles to be passed to the roles module"
  type = map(object({
    name        = string       # Role display name
    description = string       # Purpose of the role
    permissions = list(string) # List of permission strings (e.g., "routing:queue:view")
  }))
}
