## Variables

variable rg {
  type = string
  default = "test-eh-kafka"
}

variable "region" {
  type = string
  default = "westus2"
}

variable partitions {
  type = number
  default = 16
}

variable sku {
  type = string
  default = "Standard"
}

# TU for Standard EH
# PU for Premium EH
variable scale {
  type = number
  default = 1
}
