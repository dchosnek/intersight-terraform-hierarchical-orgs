output "parent_org_moids" {
  description = "Map of parent organization name to MOID."
  value       = { for name, org in intersight_organization_organization.parent : name => org.moid }
}

output "child_org_moids" {
  description = "Map of child organization name to MOID."
  value       = { for name, org in intersight_organization_organization.children : name => org.moid }
}

output "child_permission_moids" {
  description = "Map of child organization name to permission MOID."
  value       = { for name, permission in intersight_iam_permission.child_org_permission : name => permission.moid }
}
