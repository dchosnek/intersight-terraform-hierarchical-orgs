

module "intersight_org_sharing" {
  source = "./modules/intersight-org-sharing"

  parent_org_names = ["CommonPolicy", "CommonPool"]
  child_org_names  = ["Beta", "Pilot", "TME"]
  tags             = local.tags
}

output "parent_org_moids" {
  value = module.intersight_org_sharing.parent_org_moids
}
