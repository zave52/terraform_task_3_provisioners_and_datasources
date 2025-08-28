resource "null_resource" "vm_provisioner" {
  triggers = {
    vm_id = data.azurerm_virtual_machine.main.id
  }

  connection {
    type        = "ssh"
    host        = data.azurerm_public_ip.main.ip_address
    user        = var.admin_username
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    content = templatefile("${path.module}/index.html", {
      vm_name = data.azurerm_virtual_machine.main.name
    })
    destination = "/tmp/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt-get update -y",
      "sudo apt-get install -y software-properties-common",
      "sudo add-apt-repository universe -y",
      "sudo apt-get update -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install nginx -y",
      "sudo mv /tmp/index.html /var/www/html/index.html",
      "sudo chown www-data:www-data /var/www/html/index.html",
      "sudo chmod 644 /var/www/html/index.html",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }
}