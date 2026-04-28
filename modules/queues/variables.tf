# ==========================================
# Queues Module Variables
# This file defines the exact structure of the object that the root module must pass in.
# It matches the root variable definition but is localized to this module.
# ==========================================

variable "queues" {
  description = "A complex map of objects containing configuration for Genesys Cloud Queues"
  type = map(object({
    name                     = string             # (Required) Genesys Cloud display name
    description              = optional(string)   # (Optional) Description of the queue
    division_id              = optional(string)   # (Optional) Org division for access control
    division_name            = optional(string)   # (Optional) Dynamic name lookup mapping
    acw_wrapup_prompt        = optional(string)   # (Optional) After Call Work (ACW) prompt type
    acw_timeout_ms           = optional(number)   # (Optional) ACW duration in milliseconds
    skill_evaluation_method  = optional(string)   # (Optional) Routing skill evaluation (e.g., BEST)
    
    # Automated Lookup Fields for Flows and Prompts
    queue_flow_id            = optional(string)   # Direct ID for In-Queue Flow
    queue_flow_name          = optional(string)   # Human-readable name for In-Queue Flow (triggers lookup)
    queue_flow_type          = optional(string, "inqueuecall") # Category of the flow
    whisper_prompt_id        = optional(string)   # Direct ID for Whisper Prompt
    whisper_prompt_name      = optional(string)   # Human-readable name for Whisper Prompt (triggers lookup)
    
    # Feature Flags
    auto_answer_only         = optional(bool)     # If true, forces auto-answer for agents
    enable_transcription     = optional(bool)     # Enables voice transcription
    enable_audio_monitoring  = optional(bool)     # Allows supervisor monitoring
    enable_manual_assignment = optional(bool)     # Allows manual interaction assignment
    calling_party_name       = optional(string)   # Outbound caller ID name
    
    # Group Assignment (Base Routing)
    groups                   = optional(list(string)) # List of Direct Group IDs
    group_names              = optional(list(string)) # List of Group Names (triggers lookup)
    
    wrapup_codes             = optional(list(string)) # Wrap-up codes bound to queue
    default_script_ids       = optional(map(string))  # Screen-pops for different media
    
    outbound_email_address = optional(object({
      domain_id = string
      route_id  = string
    }))

    # Service Level Agreements (SLAs)
    media_settings_call = optional(object({
      alerting_timeout_sec      = optional(number) # How long an interaction alerts before jumping
      service_level_percentage  = optional(number) # Target SLA success rate percentage
      service_level_duration_ms = optional(number) # Target SLA response time
    }))

    # Rules for routing (e.g., expanding wait times based on thresholds)
    routing_rules = optional(list(object({
      operator     = string
      threshold    = number
      wait_seconds = number
    })))

    # Bullseye Routing (Expanding Agent Pools)
    bullseye_rings = optional(list(object({
      expansion_timeout_seconds = number # Time before the pool expands
      skills_to_remove          = optional(list(string))
      member_groups = optional(list(object({
        member_group_id   = optional(string) # Direct ID
        member_group_name = optional(string) # Name for lookup
        member_group_type = string           # GROUP or SKILLGROUP
      })))
    })))

    # Conditional Group Activation (Dynamic Overflow)
    conditional_group_activation = optional(object({
      pilot_rule = optional(object({         # High-level condition (e.g., Wait Time > 45s)
        condition_expression = string
        conditions = list(object({
          simple_metric = object({
            metric   = string
            queue_id = optional(string)
          })
          operator = string
          value    = number
        }))
      }))
      rules = optional(list(object({         # Specific activation rule (e.g., Idle Agents < 2)
        condition_expression = string
        conditions = list(object({
          simple_metric = object({
            metric   = string
            queue_id = optional(string)
          })
          operator = string
          value    = number
        }))
        groups = list(object({               # Groups to activate as overflow
          member_group_id   = optional(string)
          member_group_name = optional(string)
          member_group_type = string
        }))
      })))
    }))

    # Direct Agent assignment
    members = optional(list(object({
      user_id   = optional(string)
      user_name = optional(string)
      ring_num  = number
    })))
  }))
}

# ==========================================
# Dynamic Cross-Module Dependency mapping
# ==========================================
variable "created_divisions" {
  description = "Map of division names to their generated IDs from the divisions module"
  type        = map(object({
    id   = string
    name = string
  }))
  default     = {}
}

variable "created_users" {
  description = "Map of user names to their generated IDs from the users module"
  type        = map(object({
    id    = string
    name  = string
    email = string
  }))
  default     = {}
}


