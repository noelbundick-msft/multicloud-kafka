## Variables

variable rg {
  type = string
  default = "test-hdi-kafka"
}

variable "region" {
  type = string
  default = "westus2"
}

variable partitions {
  type = number
  default = 16
}

variable brokers {
  type = number
  default = 3
}

variable disks_per_node {
  type = number
  default = 1
}

variable broker_size {
  type = string
  default = "Standard_DS3_V2"
}

variable zookeeper_size {
  type = string
  default = "Standard_DS3_V2"
}

### HACKS

# Terraform azurerm_hdinsight_kafka_cluster is broken:
# The cluster must be created with 4.0
# All updates must happen with 5.0.3000.0
variable cluster_version {
  type = string
  default = "4.0"
}
