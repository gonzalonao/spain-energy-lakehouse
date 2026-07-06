locals {
  name_suffix = "${var.prefix}${var.environment}"
  tags        = merge(var.tags, { environment = var.environment })
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name_suffix}"
  location = var.location
  tags     = local.tags
}

# ADLS Gen2 (hierarchical namespace) — raw landing zone + lakehouse storage.
resource "azurerm_storage_account" "lake" {
  name                     = "st${local.name_suffix}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  tags                     = local.tags
}

resource "azurerm_storage_container" "zones" {
  for_each           = toset(["raw", "bronze", "silver", "gold"])
  name               = each.key
  storage_account_id = azurerm_storage_account.lake.id
}

resource "azurerm_data_factory" "this" {
  name                = "adf-${local.name_suffix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = local.tags

  identity {
    type = "SystemAssigned"
  }
}

# Databricks workspace is provisioned only for job runs (see ADR-0002 cost strategy);
# day-to-day notebook development happens on Databricks Free Edition.
# resource "azurerm_databricks_workspace" "this" {
#   name                = "dbw-${local.name_suffix}"
#   resource_group_name = azurerm_resource_group.this.name
#   location            = azurerm_resource_group.this.location
#   sku                 = "standard"
#   tags                = local.tags
# }
