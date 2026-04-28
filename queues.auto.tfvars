# Genesys CX as Code - Automated lookup Configuration
# 🚀 This version uses NAME-BASED lookups for Flows/Prompts and IDs for Groups.
# ⚠️ Note: If name discovery fails (e.g. for Groups), use the direct ID attributes.

queues = {
  "example_queue" = {
    name        = "Sample_Advanced_Queue"
    description = "A queue demonstrating automated Name-to-ID lookups"
    # division_name           = "my_custom_division" # <== Commented out: Requires 'All Divisions' Global Role Access
    acw_wrapup_prompt       = "MANDATORY_TIMEOUT"
    acw_timeout_ms          = 300000
    skill_evaluation_method = "BEST"

    # Automated Lookups (Working for Flows and Prompts!)
    queue_flow_name     = "Default In-Queue Flow"
    queue_flow_type     = "inqueuecall"
    whisper_prompt_name = "abc"

    auto_answer_only         = true
    enable_transcription     = true
    enable_audio_monitoring  = true
    enable_manual_assignment = true
    calling_party_name       = "Antigravity Support"

    media_settings_call = {
      alerting_timeout_sec      = 30
      service_level_percentage  = 0.8
      service_level_duration_ms = 20000
    }

    routing_rules = [
      {
        operator     = "MEETS_THRESHOLD"
        threshold    = 5
        wait_seconds = 60
      }
    ]

    bullseye_rings = [
      {
        expansion_timeout_seconds = 15
      },
      {
        expansion_timeout_seconds = 30
        member_groups = [
          {
            # Using direct ID field instead of name lookup
            member_group_id   = "e50e3457-b328-44b6-9f26-b9871b7dca91"
            member_group_type = "GROUP"
          }
        ]
      }
    ]

    conditional_group_activation = {
      pilot_rule = {
        condition_expression = "C1"
        conditions = [
          {
            simple_metric = {
              metric = "EstimatedWaitTime"
            }
            operator = "GreaterThan"
            value    = 45
          }
        ]
      }
      rules = [
        {
          condition_expression = "C1"
          conditions = [
            {
              simple_metric = {
                metric = "IdleAgentCount"
              }
              operator = "LessThan"
              value    = 2
            }
          ]
          groups = [
            {
              # Using direct ID field instead of name lookup
              member_group_id   = "e50e3457-b328-44b6-9f26-b9871b7dca91"
              member_group_type = "GROUP"
            }
          ]
        }
      ]
    }

    # Dynamically look up the user ID by mapping their terraform logical key!
    members = [
      {
        user_name = "sample_admin"
        ring_num  = 1
      }
    ]
  }
}


