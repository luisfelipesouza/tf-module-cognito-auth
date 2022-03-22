resource "random_id" "id" {
  byte_length = 4
}

locals {
  identifier = lower("${var.application}-${random_id.id.hex}")
}