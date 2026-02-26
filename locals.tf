// specify tags that will applied to each object that accepts tags
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
