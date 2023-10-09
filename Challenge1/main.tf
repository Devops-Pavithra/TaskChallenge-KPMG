
#Creating a 3-tier architecture on Azure using Terraform involves setting up infrastructure for three distinct layers: the presentation layer, application layer, and database layer.

#terraform {
#   required_providers {
#     azurerm = {
#     source = "hashicorp/azurerm"
#     version = "=2.46.0"
#      }
#   }
#}

provider "azurerm" {
  #  features {}
  client_id       = "${var.ARM_CLIENT_ID}"
  client_secret   = "${var.ARM_CLIENT_SECRET}"
  tenant_id       = "${var.ARM_TENANT_ID}"
  subscription_id = "${var.ARM_SUBSCRIPTION_ID}"
}

data "azurerm_resource_group" "main" {
  name = "${var.Resource_Group_Name}"
}

data "azurerm_resource_group" "Destination" {
  name = "${var.Destination_Resource_Group_Name}"
}

data "azurerm_virtual_network" "main" {
  name                = "${var.Virtual_Network_Name}"
  resource_group_name = "${var.Virtual_Network_RG}"
}

data "azurerm_subnet" "internal" {
  name                 = "${var.Virtual_Network_Subnet}"
  virtual_network_name = "${var.Virtual_Network_Name}"
  resource_group_name  = "${var.Virtual_Network_RG}"
}

resource "azurerm_template_deployment" "main" {
  name                = "azurerm_diskdeployment-pattern-${element(var.Pattern_items, count.index)}"
  resource_group_name = "${data.azurerm_resource_group.Destination.name}"
  count               = "${var.Total_Count}"

  template_body = <<DEPLOY
    {
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",    
    "parameters": {
         "diskName": {
            "type": "string"
        },
        "location": {
            "type": "string"
        },
        "sku": {
            "type": "string"
        },
        "sourceResourceId": {
            "type": "string"
        },
        "sourceUri": {
            "type": "string"
        },
        "osType": {
            "type": "string"
        },
        "createOption": {
            "type": "string"
        },
        "hyperVGeneration": {
            "type": "string",
            "defaultValue": "V1"
        },
        "diskEncryptionSetType": {
            "type": "string"
        }              
    },
    "resources": [
        {
           "apiVersion": "2019-07-01",
            "type": "Microsoft.Compute/disks",
            "name": "[parameters('diskName')]",
            "location": "[parameters('location')]",
            "properties": {
                "creationData": {
                    "createOption": "[parameters('createOption')]",
                    "sourceResourceId": "[parameters('sourceResourceId')]"
                },
                
                "osType": "[parameters('osType')]"
            },
            "sku": {
                "name": "[parameters('sku')]"
            }            
        }
    ]
    }
    DEPLOY

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters = {
    "diskName"              = "${element(var.Pattern_items, count.index)}"
    "location"              = "${data.azurerm_resource_group.Destination.location}"
    "sku"                   = "${element(var.StorageAccountType, count.index)}"
    "createOption"          = "copy"
    "osType"                = ""
    "sourceUri"             = ""
    "diskEncryptionSetType" = "EncryptionAtRestWithPlatformKey"
    "sourceResourceId"      = "${lookup(var.DisksList, element(var.ModulesList, count.index))}"
  }
  deployment_mode = "Incremental"
}

resource "azurerm_network_interface" "main" {
  count               = "${var.Total_Count}"
  name                = "${element(var.Pattern_items, count.index)}"
  location            = "${data.azurerm_resource_group.Destination.location}"
  resource_group_name = "${data.azurerm_resource_group.Destination.name}"

  ip_configuration {
    name                          = "testconfiguration-${element(var.Pattern_items, count.index)}"
    subnet_id                     = "${data.azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_virtual_machine" "main" {
  count                         = "${var.Total_Count}"
  name                          = "${element(var.Pattern_items, count.index)}"
  location                      = "${data.azurerm_resource_group.Destination.location}"
  resource_group_name           = "${data.azurerm_resource_group.Destination.name}"
  network_interface_ids         = ["${element(azurerm_network_interface.main.*.id, count.index)}"]
  vm_size                       = "${element(var.VM_Size, count.index)}"
  license_type                  = "Windows_Client"
  delete_os_disk_on_termination = true

  storage_os_disk {
    name            = "${element(var.Pattern_items, count.index)}"
    caching         = "ReadWrite"
    create_option   = "Attach"
    managed_disk_id = "/subscriptions/${var.ARM_SUBSCRIPTION_ID}/resourceGroups/${data.azurerm_resource_group.Destination.name}/providers/Microsoft.Compute/disks/${element(var.Pattern_items, count.index)}"
    os_type         = "Windows"
  }
  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = false
  }


  depends_on = ["azurerm_template_deployment.main", "azurerm_network_interface.main"]
}
