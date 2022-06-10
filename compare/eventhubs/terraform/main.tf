resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg
  location = var.region
}

resource "azurerm_eventhub_namespace" "default" {
  name                = "kafka-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_eventhub" "topic1" {
  name                = "topic1"
  namespace_name      = azurerm_eventhub_namespace.default.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = var.partitions
  message_retention   = 1
}

output "bootstrap_server" {
  value = "${azurerm_eventhub_namespace.default.name}.servicebus.windows.net:9093"
}

output "topic" {
  value = azurerm_eventhub.topic1.name
}

output "primary_connection_string" {
  value = azurerm_eventhub_namespace.default.default_primary_connection_string
  sensitive = true
}
