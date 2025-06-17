# Source for Rocky Linux 9
source "googlecompute" "rocky9" {
  source_image_family      = "rocky-linux-9"
  image_name               = "${var.company}-rocky9-${var.default_service_name}"

  project_id               = var.gcp_project_id
  zone                     = var.gcp_zone
  machine_type             = var.gcp_machine_type

  ssh_username             = "packer"

  image_labels = {
    "base-public-image"    = "rocky-linux-9"
  }
}

#################################################################################

# Build for Rocky Linux 9
build {
  sources = ["source.googlecompute.rocky9"]

  provisioner "shell" {
    scripts = ["../script/linux/init_script.sh"]
  }
  provisioner "file" {
    source      = "../files/linux/setting.sh"
    destination = "/tmp/linux_setting_v1.sh"
  }
  post-processor "shell-local" {
    inline = [
      "chmod +x ./files/google.sh",
      "./files/google.sh ${var.company}-rocky9-${var.default_service_name}",
    ]
  }
}
