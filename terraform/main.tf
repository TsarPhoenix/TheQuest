variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}
variable "quest_location" {}
variable "quest_rg" {}
variable "quest_name" {}
variable "environment" {}
variable "quest_prefix" {}
variable "quest_address_prefix" {}
variable "quest_address_space" {}
variable "terraform_script_version" {}
variable "domain_name_label" {}

locals {
    quest_name = var.environment == "production" ? "${var.quest_name}-prd" : "${var.quest_name}-dev"
    build_environment = var.environment == "production" ? "production" : "dev"
    }
provider "azurerm" {
    version         = "1.44.0"
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id
    subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "quest_rg" {
    name        = var.quest_rg
    location    =  var.quest_location

    tags = {
        environment = local.build_environment
        build-version = var.terraform_script_version
    }
}

resource "azurerm_virtual_network" "quest_vnet" {
  name                = "${var.quest_prefix}-vnet"
  location            = var.quest_location
  resource_group_name = azurerm_resource_group.quest_rg.name
  address_space       = [var.quest_address_space]
}

resource "azurerm_subnet" "quest_subnet" {
  name                      = "${var.quest_prefix}-subnet"
  resource_group_name       = azurerm_resource_group.quest_rg.name
  virtual_network_name      = azurerm_virtual_network.quest_vnet.name
  address_prefix            = var.quest_address_prefix
  network_security_group_id = azurerm_network_security_group.quest_nsg.id
}

resource "azurerm_network_interface" "quest_nic" {
  name                      = "${var.quest_name}-nic"
  location                  = var.quest_location
  resource_group_name       = azurerm_resource_group.quest_rg.name
  network_security_group_id = azurerm_network_security_group.quest_nsg.id

  ip_configuration {
    name                          = "${var.quest_name}-ip"
    subnet_id                     = azurerm_subnet.quest_subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.quest_public_ip.id
  }
}

resource "azurerm_public_ip" "quest_public_ip" {
  name                         = "${var.quest_name}-public-ip"
  location                     = var.quest_location
  resource_group_name          = azurerm_resource_group.quest_rg.name
  allocation_method = var.environment == "production" ? "Static" : "Dynamic"
}

resource "azurerm_network_security_group" "quest_nsg" {
  name                = "${var.quest_name}-nsg"
  location            = var.quest_location
  resource_group_name = azurerm_resource_group.quest_rg.name
}

resource "azurerm_network_security_rule" "quest_nsg_rule_ssh" {
  name                        = "SSH Inbound"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.quest_rg.name
  network_security_group_name = azurerm_network_security_group.quest_nsg.name
}

resource "azurerm_network_security_rule" "quest_nsg_rule_http" {
  name                        = "http Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1313"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.quest_rg.name
  network_security_group_name = azurerm_network_security_group.quest_nsg.name
}

resource "azurerm_virtual_machine" "quest_ubuntu_vm" {
  name                         = "${var.quest_name}-vm"
  location                     = var.quest_location
  resource_group_name          = azurerm_resource_group.quest_rg.name 
  network_interface_ids        = ["${azurerm_network_interface.quest_nic.id}"]
  vm_size                      = "Standard_B1s"

  storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
  }

  storage_os_disk {
    name              = "${var.quest_name}-os"    
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  
  os_profile {
    computer_name      = "${var.quest_name}-vm"
    admin_username     = "TheQuest"
    admin_password     = "GrainTheftVisit9!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    os = "ubuntu"
  }

}
