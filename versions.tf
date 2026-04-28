# ==========================================
# Terraform Core and Provider Configuration
# This file dictates the versions of Terraform and Providers required,
# and configures the backend where state is stored.
# ==========================================

terraform {
  # Forces anyone running this code to use at least Terraform v1.0.0
  required_version = ">= 1.0.0"

  required_providers {
    # The Genesys Cloud CX Provider block
    genesyscloud = {
      source  = "mypurecloud/genesyscloud" # The official repository for the provider
      version = "~> 1.40"                  # Use version 1.40.x (avoids breaking changes in 2.0)
    }
  }

  # Terraform Cloud Backend Configuration
  cloud {
    organization = "cg_genesys" # The HCP Terraform Organization name
    workspaces {
      # This tag logic allows us to use multiple workspaces (e.g., genesys-cx-poc, genesys-cx-prod)
      # without hardcoding a single workspace name.
      tags = ["genesys-cx"]
    }
  }
}

# Provider Initialization
provider "genesyscloud" {
  # ⚠️ SECURITY BEST PRACTICE ⚠️
  # We do NOT hardcode Genesys Cloud OAuth credentials here.
  # Instead, Terraform Cloud injects them securely via these Environment Variables:
  # - GENESYSCLOUD_OAUTHCLIENT_ID
  # - GENESYSCLOUD_OAUTHCLIENT_SECRET
  # - GENESYSCLOUD_REGION
}

