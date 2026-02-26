// Parent orgs own reusable policies/pools that will be shared to child orgs.
resource "intersight_organization_organization" "parent" {
  for_each = toset(var.parent_org_names)

  name        = each.value
  description = "Contains shared resources. Managed by Terraform."

  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

// Child orgs consume shared resources and are associated to dedicated resource groups.
resource "intersight_organization_organization" "children" {
  for_each = toset(var.child_org_names)

  name        = each.value
  description = "Contains shared resources. Managed by Terraform."

  resource_groups {
    object_type = "resource.Group"
    moid        = intersight_resource_group.resource_groups[each.key].moid
  }

  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

// One resource group per child org; referenced by the child organization resource above.
resource "intersight_resource_group" "resource_groups" {
  for_each = toset(var.child_org_names)

  name = lower("${each.value}-rg")

  dynamic "tags" {
    for_each = var.tags
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

locals {
  # Embedded admin privilege sets applied to each child org.
  # NOTE: Account-scoped privilege sets are not valid in iam_resource_roles.
  # Override this list only with resource-scoped privilege sets.
  administrator_privilege_set_names = [
    "Catalog Administrator",
    "Device Administrator",
    "HCI Cluster Administrator",
    "Integrated Systems Administrator",
    "Kubernetes Administrator",
    "Network Administrator",
    "Nexus Administrator",
    "Nexus Config Administrator",
    "SAN Administrator",
    "Server Administrator",
    "Storage Administrator",
    "UCS Domain Administrator",
    "Unified Edge Administrator",
    "Virtualization Administrator",
    "Workload Administrator",
  ]

  # One permission object per child org; this is the reusable role container.
  child_permission_names = {
    for child in var.child_org_names : child => "${child}-org-admin-plus-parent-read-only"
  }

  # For each child org, assign Read-Only on every parent org.
  child_parent_read_only_targets = {
    for pair in setproduct(var.child_org_names, var.parent_org_names) : "${pair[0]}::${pair[1]}::parent-read-only" => {
      child_org  = pair[0]
      parent_org = pair[1]
    }
  }

  org_moids_by_name = merge(
    { for name, org in intersight_organization_organization.parent : name => org.moid },
    { for name, org in intersight_organization_organization.children : name => org.moid }
  )
}

// Resolve privilege set Moids by name so we can attach by Moid instead of selector.
data "intersight_iam_privilege_set" "admin" {
  for_each = toset(local.administrator_privilege_set_names)
  name     = each.value
}

data "intersight_iam_privilege_set" "read_only" {
  name = "Read-Only"
}

// One permission object per child org.
resource "intersight_iam_permission" "child_org_permission" {
  for_each = local.child_permission_names

  name        = "${each.key} Administrator"
  description = "Administrator on ${each.key}; Read-Only on all parent orgs."
}

// Attach child-org Administrator privilege sets to each child permission object.
resource "intersight_iam_resource_roles" "child_admin_resource_roles" {
  for_each = toset(var.child_org_names)

  parent {
    object_type = "iam.Permission"
    moid        = intersight_iam_permission.child_org_permission[each.value].moid
  }

  permission {
    object_type = "iam.Permission"
    moid        = intersight_iam_permission.child_org_permission[each.value].moid
  }

  resource {
    object_type = "organization.Organization"
    moid        = local.org_moids_by_name[each.value]
  }

  dynamic "privilege_sets" {
    for_each = toset(local.administrator_privilege_set_names)
    content {
      object_type = "iam.PrivilegeSet"
      moid        = data.intersight_iam_privilege_set.admin[privilege_sets.value].moid
    }
  }
}

// Attach parent-org Read-Only privilege set to each child permission object.
resource "intersight_iam_resource_roles" "child_parent_read_only_resource_roles" {
  for_each = local.child_parent_read_only_targets

  parent {
    object_type = "iam.Permission"
    moid        = intersight_iam_permission.child_org_permission[each.value.child_org].moid
  }

  permission {
    object_type = "iam.Permission"
    moid        = intersight_iam_permission.child_org_permission[each.value.child_org].moid
  }

  resource {
    object_type = "organization.Organization"
    moid        = local.org_moids_by_name[each.value.parent_org]
  }

  privilege_sets {
    object_type = "iam.PrivilegeSet"
    moid        = data.intersight_iam_privilege_set.read_only.moid
  }
}
