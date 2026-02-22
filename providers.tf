terraform {
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = ">= 1.0.74, < 2.0.0"
    }
  }
}

provider "intersight" {
  endpoint = "https://intersight.com"
}
