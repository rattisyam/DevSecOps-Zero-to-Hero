terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

# Generate random suffix for globally unique storage account name
resource "random_id" "storage_suffix" {
  byte_length = 4
}

# Resource Group
resource "azurerm_resource_group" "vault_demo" {
  name     = "rg-vault-demo"
  location = "Central India"
}

# Storage Account (Equivalent to S3 Bucket)
resource "azurerm_storage_account" "vault_demo" {
  name                     = "vaultdemo${lower(random_id.storage_suffix.hex)}"
  resource_group_name      = azurerm_resource_group.vault_demo.name
  location                 = azurerm_resource_group.vault_demo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "Dev"
    Project     = "Vault-Demo"
  }
}

# Blob Container
resource "azurerm_storage_container" "demo" {
  name                  = "demo-container"
  storage_account_id    = azurerm_storage_account.vault_demo.id
  container_access_type = "private"
}

# Outputs
output "resource_group_name" {
  value = azurerm_resource_group.vault_demo.name
}

output "storage_account_name" {
  value = azurerm_storage_account.vault_demo.name
}

output "container_name" {
  value = azurerm_storage_container.demo.name
}
