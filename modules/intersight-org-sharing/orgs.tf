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
