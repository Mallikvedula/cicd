# ==========================================
# Root Module Calls
# These blocks instantiate the child modules located in the ./modules directory.
# We pass the root variables directly into the child modules.
# ==========================================

# 1. Divisions Module
# This module dynamically creates Divisions in Genesys Cloud.
module "divisions" {
  source    = "./modules/divisions"
  divisions = var.divisions
}

module "queues" {
  source            = "./modules/queues"                # Path to the module source code
  queues            = var.queues                        # Passing the root variable 'queues' into the module
  created_divisions = module.divisions.division_details # Explicit Dependency mapping!
  created_users     = module.users.user_details         # Explicit Dependency mapping!
}

# 3. Skills Module
# This module dynamically creates Routing Skills in Genesys Cloud.
module "skills" {
  source = "./modules/skills"
  skills = var.skills
}

# 4. Users Module
# This module is responsible for analyzing the `var.users` map and creating Genesys Cloud Users.
module "users" {
  source         = "./modules/users"           # Path to the module source code
  users          = var.users                   # Passing the root variable 'users' into the module
  created_skills = module.skills.skill_details # Explicit Dependency mapping!
}

# 5. Roles Module
# This module is responsible for analyzing the `var.roles` map and creating Genesys Cloud Authorization Roles.
module "roles" {
  source = "./modules/roles" # Path to the module source code
  roles  = var.roles         # Passing the root variable 'roles' into the module
}

# ==========================================
# State Migration (Moved Blocks)
# 
# These "moved" blocks tell Terraform state management that we have refactored our code.
# Previously, resources were created as individual objects (e.g., `poc_queue`).
# We refactored the code to use a `for_each` loop (e.g., `queues["poc_queue"]`).
# These blocks prevent Terraform from destroying the old resource and recreating it,
# instructing it instead to simply rename the address in the state file.
# ==========================================

moved {
  from = module.queues.genesyscloud_routing_queue.poc_queue
  to   = module.queues.genesyscloud_routing_queue.queues["poc_queue"]
}

moved {
  from = module.queues.genesyscloud_routing_queue.automated_queue
  to   = module.queues.genesyscloud_routing_queue.queues["automated_queue"]
}

moved {
  from = module.queues.genesyscloud_routing_queue.support_queue
  to   = module.queues.genesyscloud_routing_queue.queues["support_queue"]
}

moved {
  from = module.queues.genesyscloud_routing_queue.technical_queue
  to   = module.queues.genesyscloud_routing_queue.queues["technical_queue"]
}

moved {
  from = module.users.genesyscloud_user.example_user
  to   = module.users.genesyscloud_user.users["example_user"]
}

