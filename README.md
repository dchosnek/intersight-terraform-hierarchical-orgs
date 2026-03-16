# intersight-terraform-hierarchical-orgs

I'm using this specifically to create Parent/Child orgs for both IMM and Fleet in my Intersight account.

The module in this repo creates the parent/child relationship along with sharing rules and permissions so child orgs can consume shared resources from parents.

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

  tags = {
    orchestrator = "terraform"
    owner        = "example"
  }
}
```

## Modules

- `./modules/intersight-org-sharing`
