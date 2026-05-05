# ==========================================
# USERS CREATION
# ==========================================
users = {
  "sample_admin" = {
    name  = "Sample Admin"
    email = "admin@example.com"
    state = "active"

    # Assign the user to the newly created routing skill dynamically
    routing_skills = [
      {
        skill_name  = "my_custom_skill"
        proficiency = 4.5
      }
    ]
  }
  "sample_agent" = {
    name  = "Sample Agent"
    email = "agent@example.com"
    state = "inactive"

    # Assign the user to the newly created routing skill dynamically
    routing_skills = [
      {
        skill_name  = "my_custom_skill"
        proficiency = 4.5
      },
      {
        skill_name  = "CICD_Skill"
        proficiency = 3
      }
    ]
  }
  "sample_supervisor" = {
    name  = "Sample Supervisor"
    email = "supervisor@example.com"
    state = "active"

    # Assign the user to the newly created routing skill dynamically
    routing_skills = [
      {
        skill_name  = "my_custom_skill"
        proficiency = 4.5
      },
      {
        skill_name  = "CICD-Support"
        proficiency = 3
      }
    ]
  }
}