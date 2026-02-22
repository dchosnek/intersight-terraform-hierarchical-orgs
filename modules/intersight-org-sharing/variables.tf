variable "parent_org_names" {
  description = "Names of parent organizations that share resources to child orgs."
  type        = list(string)
}

variable "child_org_names" {
  description = "Names of child organizations that receive shared resources."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to organizations and resource groups."
  type = list(object({
    key   = string
    value = string
  }))
  default = []
}
