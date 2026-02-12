
locals {
  child_orgs = [
    { name = "beta", description = "for beta users" },
    { name = "pilot", description = "for pilot users" },
    { name = "tme", description = "for tme users" },
  ]
}

locals {
  parent_orgs = [
    { name = "CommonPolicy", description = "policy for use by other orgs" },
    { name = "CommonPool", description = "pools for use by other orgs" },
  ]
}

// Parent orgs own reusable policies/pools that will be shared to child orgs.
resource "intersight_organization_organization" "parent" {
  for_each = { for org in local.parent_orgs : org.name => org }

  name        = each.value.name
  description = each.value.description

  dynamic "tags" {
    for_each = local.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

// Child orgs consume shared resources and are associated to dedicated resource groups.
resource "intersight_organization_organization" "children" {
  for_each = { for org in local.child_orgs : org.name => org }

  name        = each.value.name
  description = each.value.description

  resource_groups {
    object_type = "resource.Group"
    moid        = intersight_resource_group.resource_groups[each.key].moid
  }

  dynamic "tags" {
    for_each = local.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

// One resource group per child org; referenced by the child organization resource above.
resource "intersight_resource_group" "resource_groups" {
  for_each = { for org in local.child_orgs : org.name => org }

  name = lower("${each.value.name}-rg")

  dynamic "tags" {
    for_each = local.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

locals {
  # Build every parent->child combination so we can create one IAM sharing rule per pair.
  # Example key: "CommonPolicy->beta"
  parent_child_shares = {
    # setproduct(a, b) returns the Cartesian product of both lists:
    # [ ["CommonPolicy","beta"], ["CommonPolicy","pilot"], ... ]
    for share in setproduct(
      [for org in local.parent_orgs : org.name],
      [for org in local.child_orgs : org.name]
    ) :
    # Use a stable, readable map key per pair for for_each addressing.
    "${share[0]}->${share[1]}" => {
      # share[0] is the parent org name; share[1] is the child org name.
      parent = share[0]
      child  = share[1]
    }
  }
}

// One IAM sharing rule per parent->child pair from local.parent_child_shares.
resource "intersight_iam_sharing_rule" "parent_child_relationship" {
  for_each = local.parent_child_shares

  shared_resource {
    object_type = "organization.Organization"
    moid        = intersight_organization_organization.parent[each.value.parent].moid
  }

  shared_with_resource {
    object_type = "organization.Organization"
    moid        = intersight_organization_organization.children[each.value.child].moid
  }
}


output "orgs" {
  value = intersight_organization_organization.parent["CommonPolicy"].moid
}
