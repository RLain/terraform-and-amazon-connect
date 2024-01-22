terraform {
    required_providers {
       aws = {
          source  = "hashicorp/aws"
          version = "4.38.0"
     }
   }
    cloud {
      organization = "example-org-c7078e"

      workspaces {
        name = "local-measure"
      }
    }
 }
provider "aws" {
  region                   = "af-south-1"
  access_key = var.access_key
  secret_key = var.secret_key
  # shared_credentials_files = ["C:/Users/rebeccalain/.aws/credentials"]
  # profile                  = "RebeccaPersonal"
}

