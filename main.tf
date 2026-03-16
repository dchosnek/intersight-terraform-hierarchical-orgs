
// ============================================================================
// org structure for IMM mode
// ----------------------------------------------------------------------------

module "imm_orgs" {
  source = "./modules/intersight-org-sharing"

  parent_org_names = [
    "Common",
  ]
  child_org_names = [
    "Beta",
    "Demo",
    "Pilot",
    "TME",
  ]

  tags = local.tags
}

// ============================================================================
// org structure for fleet management
// ----------------------------------------------------------------------------
module "fleet_orgs" {
  source = "./modules/intersight-org-sharing"

  parent_org_names = [
    "Definitions",
  ]
  child_org_names = [
    "Deployements",
    "WestCoast",
    "Mountain",
    "Central",
    "EastCoast",
  ]

  tags = local.tags
}


// ============================================================================
// outputs
// ----------------------------------------------------------------------------

output "parent_org_moids" {
  value = module.imm_orgs.parent_org_moids
}

output "child_org_moids" {
  value = module.imm_orgs.child_org_moids
}
