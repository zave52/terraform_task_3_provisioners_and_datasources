resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = data.azurerm_resource_group.example.location
  resource_group_name   = data.azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_B1s"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }

  provisioner "file" {
    connection {
      type     = "ssh"
      user     = "testadmin"
      password = "Password1234!"
      host     = azurerm_public_ip.main.ip_address
    }

    source      = "./index.html"
    destination = "/tmp/index.html"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "testadmin"
      password = "Password1234!"
      host     = azurerm_public_ip.main.ip_address
    }

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
