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

resource "azapi_resource" "hdinsight_kafka" {
  type      = "Microsoft.HDInsight/clusters@2021-06-01"
  name      = "kafka-${random_string.suffix.result}"
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location
  body = jsonencode({
    properties = {
      clusterVersion = "4.0"
      osType         = "Linux"
      tier           = "Standard"
      clusterDefinition = {
        kind = "KAFKA"
        componentVersion = {
          Kafka = "2.4"
        }
        configurations = {
          gateway = {
            "restAuthCredential.isEnabled" = true,
            "restAuthCredential.username"  = "ambari"
            "restAuthCredential.password"  = random_password.default.result
          }
        }
      }
      storageProfile = {
        storageaccounts = [
          {
            name      = replace(replace(azurerm_storage_account.hdinsight.primary_blob_endpoint, "https://", ""), "/", "")
            isDefault = true
            container = azurerm_storage_container.hdinsight.name
            key       = azurerm_storage_account.hdinsight.primary_access_key
          }
        ]
      }
      computeProfile = {
        roles = [
          {
            name                = "headnode"
            minInstanceCount    = 1
            targetInstanceCount = 2
            hardwareProfile = {
              vmSize = "Standard_E4_V3"
            }
            osProfile = {
              linuxOperatingSystemProfile = {
                username = "azureuser"
                password = random_password.default.result
              }
            }
          },
          {
            name                = "workernode"
            targetInstanceCount = 4
            hardwareProfile = {
              vmSize = "Standard_E4_V3"
            }
            osProfile = {
              linuxOperatingSystemProfile = {
                username = "azureuser"
                password = random_password.default.result
              }
            }
            dataDisksGroups = [
              {
                disksPerNode = 2
              }
            ]
          },
          {
            name                = "zookeepernode"
            minInstanceCount    = 1
            targetInstanceCount = 3
            hardwareProfile = {
              vmSize = "Standard_A4_V2"
            }
            osProfile = {
              linuxOperatingSystemProfile = {
                username = "azureuser"
                password = random_password.default.result
              }
            }
          }
        ]
      }
      minSupportedTlsVersion = "1.2"
      encryptionInTransitProperties = {
        isEncryptionInTransitEnabled = true
      }
    }
  })
}

data "azurerm_hdinsight_cluster" "hdinsight_kafka" {
  name                = azapi_resource.hdinsight_kafka.name
  resource_group_name = azurerm_resource_group.rg.name
}


output "ssh_endpoint" {
  value = data.azurerm_hdinsight_cluster.hdinsight_kafka.ssh_endpoint
}

# `terraform output -o json` will unicode escape special characters, so it can't be used as-is
output "password" {
  value     = random_password.default.result
  sensitive = true
}
