
locals {
  description = "Created by Terraform. Do not edit manually."
}

locals {
  tags = [
    {
      key   = "orchestrator"
      value = "terraform"
    },
    {
      key   = "owner"
      value = "dchosnek"
    }
  ]
}
