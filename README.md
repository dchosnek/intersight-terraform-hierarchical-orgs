# terraform-intersight-hierarchical-orgs

Creates a parent/child organization hierarchy in Cisco Intersight, with sharing rules and permissions so child orgs can consume shared resources from parents.

## Overview

- Parent orgs hold shared policies/pools.
- Child orgs each get a resource group.
- Every parent shares to every child.
- Each child org gets a permission object with Administrator privileges in its own org and Read-Only access to all parents.

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

## Modules

- `./modules/intersight-org-sharing`

