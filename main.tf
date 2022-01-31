terraform {
  backend "pg" {
    schema_name = "tf-plex"
  }
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.4"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://10.0.0.100:8006/api2/json"
}


module "plex" {
  source       = "./modules/plex"
  pve_host     = "10.0.0.100"
  pve_user     = "root"
  pve_password = "M0rgue@42"
  hostname     = "izu-hl-plex"
  domain_name  = "izunadropx.local.lan"
}