resource "proxmox_vm_qemu" "plex" {
  name        = "IZU-HL-PLEX"
  target_node = "IZU-HL-PVE03"
  os_type     = "cloud-init"
  clone       = "debian-cloudinit"

  # Cloud init options
  cicustom  = "user=IZU-HL-ISOS:snippets/${var.hostname}_user_data.yml"
  ipconfig0 = "ip=10.0.0.11/24,gw=10.0.0.1"
  cores     = 4
  memory    = 2048
  agent     = 1

  # Set the boot disk paramters
  bootdisk = "scsi0"
  scsihw   = "virtio-scsi-pci"

  disk {
    size    = "10G"
    type    = "scsi"
    storage = "IZU-HL-ZFS"
    cache   = "writethrough"
  }
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  # Ignore changes to the network
  ## MAC address is generated on every apply, causing
  ## TF to think this needs to be rebuilt on every apply
  lifecycle {
    ignore_changes = [
      network
    ]
  }
}
# Cloud Init Setting


data "template_file" "user_data" {
  template = file("${path.module}/files/user_data.template.cfg")
  vars = {
    pubkey         = file(pathexpand("${path.module}/files/ssh_keys/id_rsa.pub"))
    hostname       = "${var.hostname}"
    fqdn           = "${var.hostname}.${var.domain_name}"
    github_key_b64 = "LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0KYjNCbGJuTnphQzFyWlhrdGRqRUFBQUFBQkc1dmJtVUFBQUFFYm05dVpRQUFBQUFBQUFBQkFBQUJsd0FBQUFkemMyZ3RjbgpOaEFBQUFBd0VBQVFBQUFZRUF3WjduTjBYNDcyZmRUb01DN0ZXa2hIMUV6L0hMSWxXbnIrR3BXQ0ltbDZoRnhNMkFBQTFkCmVwRUJUY1ZVVnFrY1M4M0hVWGo5V3oxOVViNW9adjQ3Y0FXWFZsQUR1Vk1RZWhHend0RmEvVjA4eVpIU2kzblFVK0dSRXUKQ0J3WUxyNTFzeCt2Rms5S244enVvc1hKbnRGbW1lai82cnNrRVYwUDhCZHlrd0x2Z0NhM0E3VEQrOVhpNm5VdmNhUy9zOQp2citOZk1tbFZrN3IwZHQyWmZvSzVkMWM4RnIwTi9JSDR3RDBWdWFHcXJNUXZ3b2hJd2lYek9DbEJ0c1dwV09rVjBWanpLCmpSWEFaNTVlV1lPMXZXeUhaMjlNdTNSY1dCY3N4dk82YWVzMm5NVnZzVWdlekpRSW9TRWhVcjVhQnVGOE5XSVBzUGxzTm0KM1BSQmx0Z2pXUFZKNFV2MXhKTncrSng1UmhqS1ZtNVZ2Q0Vrcm5mSVZqbXc1MklxQjFGZnlXc3FlS2lUQ1hyQWhhVG1ZbQorQ1VGVlVQd3A3d0tTT2ZZU282QzBqZG0xZFRhRWVFUURhNmJrRWVOdllxVFFqa0JDMTRncStSQWtab1V5UTJzVHlOaGVMCmt4Y2NGL3hETWNjT3crTGVFM016bDVYTVErRisrUlQ4Q2djaFczNHJBQUFGa0ZNTmZzbFREWDdKQUFBQUIzTnphQzF5YzIKRUFBQUdCQU1HZTV6ZEYrTzluM1U2REF1eFZwSVI5Uk0veHl5SlZwNi9ocVZnaUpwZW9SY1ROZ0FBTlhYcVJBVTNGVkZhcApIRXZOeDFGNC9WczlmVkcrYUdiK08zQUZsMVpRQTdsVEVIb1JzOExSV3YxZFBNbVIwb3Q1MEZQaGtSTGdnY0dDNitkYk1mCnJ4WlBTcC9NN3FMRnlaN1JacG5vLytxN0pCRmREL0FYY3BNQzc0QW10d08wdy92VjR1cDFMM0drdjdQYjYvalh6SnBWWk8KNjlIYmRtWDZDdVhkWFBCYTlEZnlCK01BOUZibWhxcXpFTDhLSVNNSWw4emdwUWJiRnFWanBGZEZZOHlvMFZ3R2VlWGxtRAp0YjFzaDJkdlRMdDBYRmdYTE1ienVtbnJOcHpGYjdGSUhzeVVDS0VoSVZLK1dnYmhmRFZpRDdENWJEWnR6MFFaYllJMWoxClNlRkw5Y1NUY1BpY2VVWVl5bFp1VmJ3aEpLNTN5Rlk1c09kaUtnZFJYOGxyS25pb2t3bDZ3SVdrNW1KdmdsQlZWRDhLZTgKQ2tqbjJFcU9ndEkzWnRYVTJoSGhFQTJ1bTVCSGpiMktrMEk1QVF0ZUlLdmtRSkdhRk1rTnJFOGpZWGk1TVhIQmY4UXpISApEc1BpM2hOek01ZVZ6RVBoZnZrVS9Bb0hJVnQrS3dBQUFBTUJBQUVBQUFHQkFJSnh4UUtuSUt4aVJHWVZ1ODF2Y1pSVk5SCndIb2J4ekNyTmpEQTAxak55VjROTlRRODVGTXRwVmdSUmRRcEhVQXgxSytPTDU2VzhrQVI4bWNmNFpmLy9idEhiUkY0RXUKNWlYbmNUMXFnS3U3dWkxdkVmTW4wV1FCenhSeHJ0bXBrN2RkNkZGUmVwdWZQcFJFamppZzkyc25JMDJOM1MwTnpsM3N2NQpjQlo5WHMvdXhWUTQzK1QxMTVmdjlWUFNFOWxmN0IzTmZhbm9xRVJ6b3VhaGtRR1hGOTdwUjhJcGJpZDgvSEg5YkFIckE0ClRhcjNieFhFUDBrbmUrY2ZpYVZKZUExdnhCYVkzOEhtUUVvd3RHUlhRRjJRaTUvak02S3MrQklNa2E1K0xXZTFXcUVILzMKdk05c2hReTV6T1pNRXIvTDMvejJZMkFIKzFSTGRBSzlYMmoxb045RGZPTDJyMjRjVVk2dk4xUkQ0VUpST05icW5vYW8vNAovTzlXZ2doSDlVMTRQd1hiQVJUTnNod3FCRGYvcEpCOGRJV2g1bEdPYWwwdlc3QVN5MlVGNGEzb3B6S1k0amluQzlnd2s0CmpKR1ZEcElOeVBZUVpFUXlrelVHcmNNOUQvVTZGcTVsMWpyeFFVem5RUnc5Nmt5akZ3S01NSFUrMTVmQjJzZkcvbk9RQUEKQU1FQTFGSjBaUVZ2eDJWQUR0QXpzOTRSWVRySk1DZXEwQ3hiekx0UTBROS9nWEJ2Ni8vQ2hOT3pPZm5Wdmw1b21GcmZLUQp0WmZBTzdyclJhRGxqTWx6K0U3ZWUrRnZHRkZ4Q2h6YTBvS1BwdGtvYkh2OEswaDkxbktORG13N1BzYStPdHM3d1NFVjNMClBPZ3JoYWNPSGV4Yjl0RHB3YkttdlRRNXlwVk13SWgvYVRrMjZOaHFXMGdscDFONjhtNEd5cUJqbnNuVlFtU09JU08xd0cKVzJPTlZQSVlFWFZTdE14NXpvRlc2U1lsRThjbnY5dmxqT3FCdTdGNTY5d0MrdzJYTUVBQUFBd1FEcXI4M1BjeVI1am1nQwpBUUJRNEVDT3UrdnJ5cmFkUGpnK05ONjRNbGhHdUhtSEhzNHJSc1FNU29lUncyUUxkMVVHQ2ZSdE12UDhjeks4MDhwK0ZTCmxuME1GaEpwWnRVTjZiUCtWeUhUL1I2Uy9lUkovRFRQalVab3RyR083MCszRHFQNk41UkpyMmI5U2N3VjB5QjBId0RCbE4Kak9XQ3pEMm5tTC8xQnZKTCtYT0s3bFBaN09XeS9uamMyd2htUHFybDBwUDBMRDN0eVRJdHVoNG95cGUvZkRseENWaDlnSgpIaUd5Nzk4Z0R2VDl2RUlvTGlRL3N5R0E5cUZJRm02bzhBQUFEQkFOTTBYSlN1NUhvMWZ2UkhOdUZJaXZHUktWcDVFS0IwClFLVy9rUTFteWh3aGJSOEM2bU9LYkpaRUpTTURDbEZDV1V0Q3NDVEE5MkpkSG9CdFFtNjZBVVhja29oVW1KUDdJVXd3a0gKeDR4N0pGSVkzL0crUXNvbHlLVXVaRmREOUR2RXNMZVJmbmhVeENRaUlGa3VnUGNocmd1Z2VWbWtISWk2MGZXY25TNncwcQpWb1ZoNVRLYmNuS3F4WmdSMW81ZFArRVBkekRkSnh6OG1TUUZQVXpjMStRR3NOUHBLQmxQRFFzR0EwbHIyNHRad0swU09nClAxbDcyejlXYnVyUHl3cFFBQUFCbE1TRzlrWkdWeVFFMWhZMEp2YjJzdFVISnZMbXh2WTJGcwotLS0tLUVORCBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0K"
  }
}
resource "local_file" "cloud_init_user_data_file" {
  content  = data.template_file.user_data.rendered
  filename = "${path.module}/files/${var.hostname}_user_data.cfg"
}

resource "null_resource" "cloud_init_config_files" {
  connection {
    type     = "ssh"
    user     = var.pve_user
    password = var.pve_password
    host     = var.pve_host
  }

  provisioner "file" {
    source      = local_file.cloud_init_user_data_file.filename
    destination = "/mnt/pve/IZU-HL-ISOS/snippets/${var.hostname}_user_data.yml"

    connection {
      type     = "ssh"
      user     = "root"
      host     = "10.0.0.101"
      password = "M0rgue@42"
    }
  }
}

