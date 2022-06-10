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
