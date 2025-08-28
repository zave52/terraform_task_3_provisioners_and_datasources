data "azurerm_virtual_machine" "main" {
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.main.name
}



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
      "sudo apt update",
      "sudo apt install -y nginx",
      "sudo cp /tmp/index.html /var/www/html/index.html",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }
}