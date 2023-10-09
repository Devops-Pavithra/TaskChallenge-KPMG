variable ARM_SUBSCRIPTION_ID {
  default = "__AzureSubscriptionID__"
}

variable ARM_CLIENT_ID {
  default = "__AzureClientID__"
}

variable ARM_CLIENT_SECRET {
  default = "__AzureAuthKey__"
}

variable ARM_TENANT_ID {
  default = "__AzureTenantId__"
}

variable "Resource_Group_Name" {
  default = "__RESOURCEGROUPNAME__"
}

variable "Destination_Resource_Group_Name" {
  default = "__destinationResourceGroup__"
}

variable "Virtual_Network_Name" {
  default = "__vnetName__"
}

variable "Virtual_Network_RG" {
  default = "__VnetRG__"
}

variable "Virtual_Network_Subnet" {
  default = "__subnetName__"
}

variable "Storage_Account_Name" {
  default = "__StorageName__"
}

variable "Storage_Account_Key" {
  default = "__StorageAccountKey__"
}

variable "Mount_Name" {
  default = "devops"
}

variable "VM_Size" {
  type    = list
  default = __VM_Size__
}

variable "StorageAccountType" {
  type    = list
  default = __StorageAccountType__
}

variable "Total_Count" {
  default = __TotalCount__
}

variable "VMPrerequisite" {
  default = "https://MYSTORAGEACCOUNTBLOB-SCRIPT-LINK"
}

variable "DisksList" {
  type = map
  default = {
    "__MYINPUTMODULE__"      = "/subscriptions/__SUNSCRIPTIONID__/resourceGroups/__RESOURCEGROUP__/providers/Microsoft.Compute/snapshots/__MYMODULEImage__"
    
  }
}
