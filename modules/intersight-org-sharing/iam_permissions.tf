locals {
  # Built-in admin role names applied to each child org.
  administrator_role_names = [
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

// Resolve role Moids by name so we can attach by Moid instead of selector.
data "intersight_iam_role" "by_name" {
  for_each = toset(concat(local.administrator_role_names, ["Read-Only"]))
  name     = each.value
}

// One permission object per child org.
resource "intersight_iam_permission" "child_org_permission" {
  for_each = local.child_permission_names

  name        = "${each.key} Administrator"
  description = "Administrator on ${each.key}; Read-Only on all parent orgs."
}

// Attach child-org Administrator roles to each child permission object.
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

  dynamic "roles" {
    for_each = toset(local.administrator_role_names)
    content {
      object_type = "iam.Role"
      moid        = one(data.intersight_iam_role.by_name[roles.value].results).moid
    }
  }
}

// Attach parent-org Read-Only role to each child permission object.
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

  roles {
    object_type = "iam.Role"
    moid        = one(data.intersight_iam_role.by_name["Read-Only"].results).moid
  }
}
