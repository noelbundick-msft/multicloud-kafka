resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg
  location = var.region
}

resource "random_password" "default" {
  length = 16
}

# `terraform output -o json` will unicode escape special characters, so it can't be used as-is
output "password" {
  value     = random_password.default.result
  sensitive = true
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
  name                = "kafka-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  cluster_version     = var.cluster_version
  # cluster_version = "4.0"
  # cluster_version = "5.0.3000.0"  # The RP returns a different version. Terraform will delete the cluster if not addressed on deployments 2 & beyond

  tier                          = "Standard"
  tls_min_version               = "1.2"
  encryption_in_transit_enabled = true

  component_version {
    kafka = "2.4"
  }

  gateway {
    username = "azureuser"
    password = random_password.default.result
  }

  storage_account {
    storage_container_id = azurerm_storage_container.hdinsight.id
    storage_account_key  = azurerm_storage_account.hdinsight.primary_access_key
    is_default           = true
  }

  # seems broken - can't deploy without this
  # rest_proxy {
  #   security_group_id = "10ba614d-8a77-4cc1-b081-c240b4026a3a"
  #   security_group_name = "Noel Bundick FTE"
  # }

  roles {
    head_node {
      vm_size  = "Standard_DS3_V2"
      username = "azureuser"
      password = random_password.default.result
    }

    worker_node {
      vm_size                  = var.broker_size
      username                 = "azureuser"
      password                 = random_password.default.result
      number_of_disks_per_node = var.disks_per_node
      target_instance_count    = var.brokers
    }

    zookeeper_node {
      vm_size  = var.zookeeper_size
      username = "azureuser"
      password = random_password.default.result
    }
  }
}

output "ssh_endpoint" {
  value = azurerm_hdinsight_kafka_cluster.kafka.ssh_endpoint
}
