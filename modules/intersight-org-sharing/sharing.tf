locals {
  # Build every parent->child combination so we can create one IAM sharing rule per pair.
  # Example key: "CommonPolicy->beta"
  parent_child_shares = {
    # setproduct(a, b) returns the Cartesian product of both lists:
    # [ ["CommonPolicy","beta"], ["CommonPolicy","pilot"], ... ]
    for share in setproduct(var.parent_org_names, var.child_org_names) :
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
