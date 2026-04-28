# ==========================================
# Queues Module Main Resource File
# This file iterates through the `var.queues` map and provisions Genesys Cloud Queues.
# It also includes automated "data" lookups to find resource IDs by name.
# ==========================================

resource "genesyscloud_routing_queue" "queues" {
  # Iterates through every object in the `var.queues` map passed from root
  for_each = var.queues

  # Basic configuration mapped directly from variables
  name                     = each.value.name
  description              = each.value.description
  
  # Automatically maps to a direct ID, dynamic named division, or the 'home' division.
  division_id              = each.value.division_id != null ? each.value.division_id : (
    each.value.division_name != null ? var.created_divisions[each.value.division_name].id : data.genesyscloud_auth_division_home.home.id
  )
  acw_wrapup_prompt        = each.value.acw_wrapup_prompt
  acw_timeout_ms           = each.value.acw_timeout_ms
  skill_evaluation_method  = each.value.skill_evaluation_method
  
  # Automated Validation for Flows:
  # Uses the provided explicit ID first. If null, tries to use the Name-based data lookup ID.
  queue_flow_id            = each.value.queue_flow_id != null ? each.value.queue_flow_id : (each.value.queue_flow_name != null ? data.genesyscloud_flow.flows[each.value.queue_flow_name].id : null)
  
  # Automated Validation for Whisper Prompts:
  # Uses explicit ID first, falls back to Name-based data lookup ID.
  whisper_prompt_id        = each.value.whisper_prompt_id != null ? each.value.whisper_prompt_id : (each.value.whisper_prompt_name != null ? data.genesyscloud_architect_user_prompt.prompts[each.value.whisper_prompt_name].id : null)
  
  auto_answer_only         = each.value.auto_answer_only
  enable_transcription     = each.value.enable_transcription
  enable_audio_monitoring  = each.value.enable_audio_monitoring
  enable_manual_assignment = each.value.enable_manual_assignment
  calling_party_name       = each.value.calling_party_name
  
  # Group Assignment: Combines explicit IDs and Name-based lookup IDs, then removes duplicates/nulls
  groups = distinct(compact(concat(
    each.value.groups != null ? each.value.groups : [],
    each.value.group_names != null ? [for g in each.value.group_names : data.genesyscloud_group.groups[g].id] : []
  )))
  
  wrapup_codes             = each.value.wrapup_codes
  default_script_ids       = each.value.default_script_ids

  # Dynamic Block: Only created if outbound_email_address is provided in the tfvars
  dynamic "outbound_email_address" {
    for_each = each.value.outbound_email_address != null ? [each.value.outbound_email_address] : []
    content {
      domain_id = outbound_email_address.value.domain_id
      route_id  = outbound_email_address.value.route_id
    }
  }

  # Dynamic Block: SLA Media Settings
  dynamic "media_settings_call" {
    for_each = each.value.media_settings_call != null ? [each.value.media_settings_call] : []
    content {
      alerting_timeout_sec      = media_settings_call.value.alerting_timeout_sec
      service_level_percentage  = media_settings_call.value.service_level_percentage
      service_level_duration_ms = media_settings_call.value.service_level_duration_ms
    }
  }

  # Dynamic Block: Routing Rules for expanding evaluations
  dynamic "routing_rules" {
    for_each = each.value.routing_rules != null ? each.value.routing_rules : []
    content {
      operator     = routing_rules.value.operator
      threshold    = routing_rules.value.threshold
      wait_seconds = routing_rules.value.wait_seconds
    }
  }

  # Dynamic Block: Bullseye Rings for expanding agent routing pools based on time
  dynamic "bullseye_rings" {
    for_each = each.value.bullseye_rings != null ? each.value.bullseye_rings : []
    content {
      expansion_timeout_seconds = bullseye_rings.value.expansion_timeout_seconds
      skills_to_remove          = bullseye_rings.value.skills_to_remove

      # Nested Dynamic Block for groups assigned to this specific ring
      dynamic "member_groups" {
        for_each = bullseye_rings.value.member_groups != null ? bullseye_rings.value.member_groups : []
        content {
          # Automated Validation: Use explicit Group ID, fall back to Name-based lookup ID
          member_group_id   = member_groups.value.member_group_id != null ? member_groups.value.member_group_id : (member_groups.value.member_group_name != null ? data.genesyscloud_group.groups[member_groups.value.member_group_name].id : null)
          member_group_type = member_groups.value.member_group_type
        }
      }
    }
  }

  # Dynamic Block: Conditional Group Activation (Pilot condition vs Specific rule condition)
  dynamic "conditional_group_activation" {
    for_each = each.value.conditional_group_activation != null ? [each.value.conditional_group_activation] : []
    content {
      # Pilot Rule defines the overall threshold that must be met to trigger CGA
      dynamic "pilot_rule" {
        for_each = conditional_group_activation.value.pilot_rule != null ? [conditional_group_activation.value.pilot_rule] : []
        content {
          condition_expression = pilot_rule.value.condition_expression
          dynamic "conditions" {
            for_each = pilot_rule.value.conditions
            content {
              dynamic "simple_metric" {
                for_each = [conditions.value.simple_metric]
                content {
                  metric   = simple_metric.value.metric
                  queue_id = simple_metric.value.queue_id
                }
              }
              operator = conditions.value.operator
              value    = conditions.value.value
            }
          }
        }
      }

      # Specific Rules define exactly which groups to activate when the Pilot is met
      dynamic "rules" {
        for_each = conditional_group_activation.value.rules != null ? conditional_group_activation.value.rules : []
        content {
          condition_expression = rules.value.condition_expression
          dynamic "conditions" {
            for_each = rules.value.conditions
            content {
              dynamic "simple_metric" {
                for_each = [conditions.value.simple_metric]
                content {
                  metric   = simple_metric.value.metric
                  queue_id = simple_metric.value.queue_id
                }
              }
              operator = conditions.value.operator
              value    = conditions.value.value
            }
          }
          # Groups activated by this rule (Supports Automated Name Lookup)
          dynamic "groups" {
            for_each = rules.value.groups
            content {
              member_group_id   = groups.value.member_group_id != null ? groups.value.member_group_id : (groups.value.member_group_name != null ? data.genesyscloud_group.groups[groups.value.member_group_name].id : null)
              member_group_type = groups.value.member_group_type
            }
          }
        }
      }
    }
  }

  # Member Management: Specific user IDs assigned to rings
  dynamic "members" {
    for_each = each.value.members != null ? each.value.members : []
    content {
      user_id  = members.value.user_id != null ? members.value.user_id : var.created_users[members.value.user_name].id
      ring_num = members.value.ring_num
    }
  }
}

# ==========================================
# Automated Name Discovery (Data Lookups)
# These blocks query the Genesys Cloud API to find the UUIDs associated with human-readable names.
# ==========================================

# 1. Finds the default 'Home' division ID if no custom division is provided
data "genesyscloud_auth_division_home" "home" {}

# 2. Iterates over all requested `queue_flow_name`s, queries the API, and caches their IDs
data "genesyscloud_flow" "flows" {
  for_each = toset([for q in var.queues : q.queue_flow_name if q.queue_flow_name != null])
  name     = each.value
  type     = [for q in var.queues : q.queue_flow_type if q.queue_flow_name == each.value][0] # Requires the correct flow type
}

# 3. Iterates over all requested `whisper_prompt_name`s and caches their IDs
data "genesyscloud_architect_user_prompt" "prompts" {
  for_each = toset([for q in var.queues : q.whisper_prompt_name if q.whisper_prompt_name != null])
  name     = each.value
}

# 4. Complex Data Lookup: Iterates over ALL areas of the configuration (root, bullseye rings, CGA rules)
# looking for `group_names`, flattens them into a single list, queries the API, and caches their IDs
data "genesyscloud_group" "groups" {
  for_each = toset(distinct(compact(concat(
    flatten([for q in var.queues : q.group_names if q.group_names != null]),
    flatten([for q in var.queues : [for b in (q.bullseye_rings != null ? q.bullseye_rings : []) : [for m in (b.member_groups != null ? b.member_groups : []) : m.member_group_name if m.member_group_name != null]] if q.bullseye_rings != null]),
    flatten([for q in var.queues : [for r in (q.conditional_group_activation != null && q.conditional_group_activation.rules != null ? q.conditional_group_activation.rules : []) : [for g in (r.groups != null ? r.groups : []) : g.member_group_name if g.member_group_name != null]] if q.conditional_group_activation != null])
  ))))
  name = each.value
}

