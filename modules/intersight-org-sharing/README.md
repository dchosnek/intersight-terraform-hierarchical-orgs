# intersight-org-sharing module

Creates an Intersight organization hierarchy with:
- parent organizations
- child organizations
- one resource group per child organization
- IAM sharing rules from every parent org to every child org
- child org permissions that grant Administrator privileges in the child org and Read-Only in all parents

## Relationship Diagram

```text
Parent Orgs                           Child Orgs + Resource Groups
-----------                           -----------------------------
[parent1] --\                    /-> [child1] -> [child1-rg]
               +--(shared)--->+
[parent2] --/                    \-> [child2] -> [child2-rg]
                                   \-> [child3] -> [child3-rg]

Note: Sharing is many-to-many from all parents to all children.
```

## Usage

```hcl
module "intersight_org_sharing" {
  source = "./modules/intersight-org-sharing"

  parent_org_names = ["parent1", "parent2"]
  child_org_names  = ["child1", "child2", "child3"]
  tags = [
    {
      key   = "orchestrator"
      value = "terraform"
    },
    {
      key   = "owner"
      value = "example"
    }
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_intersight"></a> [intersight](#provider\_intersight) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [intersight_iam_permission.child_org_permission](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/iam_permission) | resource |
| [intersight_iam_resource_roles.child_admin_resource_roles](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/iam_resource_roles) | resource |
| [intersight_iam_resource_roles.child_parent_read_only_resource_roles](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/iam_resource_roles) | resource |
| [intersight_iam_sharing_rule.parent_child_relationship](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/iam_sharing_rule) | resource |
| [intersight_organization_organization.children](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/organization_organization) | resource |
| [intersight_organization_organization.parent](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/organization_organization) | resource |
| [intersight_resource_group.resource_groups](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/resource_group) | resource |
| [intersight_iam_privilege_set.admin](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/iam_privilege_set) | data source |
| [intersight_iam_privilege_set.read_only](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/iam_privilege_set) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_child_org_names"></a> [child\_org\_names](#input\_child\_org\_names) | Names of child organizations that receive shared resources. | `list(string)` | n/a | yes |
| <a name="input_parent_org_names"></a> [parent\_org\_names](#input\_parent\_org\_names) | Names of parent organizations that share resources to child orgs. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to organizations and resource groups. | <pre>list(object({<br/>    key   = string<br/>    value = string<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_child_org_moids"></a> [child\_org\_moids](#output\_child\_org\_moids) | Map of child organization name to MOID. |
| <a name="output_child_permission_moids"></a> [child\_permission\_moids](#output\_child\_permission\_moids) | Map of child organization name to permission MOID. |
| <a name="output_parent_org_moids"></a> [parent\_org\_moids](#output\_parent\_org\_moids) | Map of parent organization name to MOID. |
<!-- END_TF_DOCS -->
