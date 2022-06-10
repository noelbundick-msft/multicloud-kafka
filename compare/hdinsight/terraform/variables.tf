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

variable "ssh_public_key" {
  type = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6AFcA/V7n/ojV1yDw0mMjbbmzx0Fr/dILCqTr3UjDGDEquAak8/aXlfWzyBNt1frYByNSQeGvMRmoJT6sKGrkv+QnUxkWA4spCKkiHKGe9ANP/6PCQCe+SmdSPSMCP8TLE+o0XV18AFcYioyh9SokjKuiAsryBmy2jt8NQY+h6Bb+HlmtIt7JTkDOnC+AckyEW5D8rx4ni4hLlrc9J0hvA+XQh4LLlCtL3v6ZzjA/PHdCcYZrpffq4MU+EyT/teLZkMsHmMFkfkR4axApgtG5RvZurGrnFbFTtLYwtNK6aGfya+GoyBv3fp0BiiGRb+PPhqXF5cAjXVEtn17MnBod"
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
