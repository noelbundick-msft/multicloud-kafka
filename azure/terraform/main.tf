terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "ssh_public_key" {
  type = string
}

resource "azurerm_resource_group" "rg" {
  name     = "trash1-kafka"
  location = "westus3"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "random_password" "ambari" {
  length = 16
}

# `terraform output -o json` will unicode escape special characters, so it can't be used as-is
output ambari_password {
  value     = random_password.ambari.result
  sensitive = true
}

resource "azurerm_log_analytics_workspace" "kafka" {
  name                = "kafka-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "hdinsight" {
  name                     = "hdi${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "hdinsight" {
  name                  = "hdinsight"
  storage_account_name  = azurerm_storage_account.hdinsight.name
  container_access_type = "private"
}

resource "azurerm_hdinsight_kafka_cluster" "kafka" {
  name                          = "kafka-${random_string.suffix.result}"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  # cluster_version               = "4.0" # must change. Terraform will delete the cluster
  cluster_version = "5.0.3000.0"

  tier                          = "Standard"
  # tls_min_version               = "1.2" # deletes the cluster
  # encryption_in_transit_enabled = true  # deletes the cluster

  component_version {
    kafka = "2.4"
  }

  gateway {
    username = "ambari"
    password = random_password.ambari.result
  }

  storage_account {
    storage_container_id = azurerm_storage_container.hdinsight.id
    storage_account_key  = azurerm_storage_account.hdinsight.primary_access_key
    is_default           = true
  }

  # should we use?
  # * storage_account_gen2
  # * rest_proxy
  rest_proxy {
    security_group_id = "10ba614d-8a77-4cc1-b081-c240b4026a3a"
    security_group_name = "Noel Bundick FTE"
  }

  monitor {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.kafka.workspace_id
    primary_key = azurerm_log_analytics_workspace.kafka.primary_shared_key
  }

  roles {
    head_node {
      vm_size  = "Standard_DS3_V2"
      username = "azureuser"
      ssh_keys = ["${var.ssh_public_key}"]

      # subnet_id = 
      # virtual_network_id = 
    }

    worker_node {
      vm_size                  = "Standard_DS3_V2"
      username                 = "azureuser"
      ssh_keys                 = ["${var.ssh_public_key}"]
      number_of_disks_per_node = 1
      target_instance_count    = 3

      # subnet_id = 
      # virtual_network_id = 
    }

    zookeeper_node {
      vm_size  = "Standard_DS3_V2"
      username = "azureuser"
      ssh_keys = ["${var.ssh_public_key}"]

      # subnet_id = 
      # virtual_network_id = 
    }

    kafka_management_node {
      vm_size  = "Standard_DS3_V2"
      #username = "azureuser" # must change or terraform will delete the cluster
      username = "kmuser09f89"
      ssh_keys = ["${var.ssh_public_key}"]

      # subnet_id = 
      # virtual_network_id = 
    }
  }
}
