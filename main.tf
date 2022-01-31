terraform {
  backend "pg"{
      schema_name = "tf-plex"
  }
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.4"
    }
  }
}

module "plex" {
    source = "./modules/plex"
}