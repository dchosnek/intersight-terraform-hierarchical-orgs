
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
    "Fleet",
    "TME",
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
