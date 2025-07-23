variable "record_type" {
  description = "A or TXT"
  type        = string
}

variable "zone_id" {
  type = string
}

variable "name" {
  type = string
}

# A 레코드용
variable "alias_name" {
  type    = string
  default = ""
}

variable "alias_zone_id" {
  type    = string
  default = ""
}

variable "evaluate_target_health" {
  type    = bool
  default = false
}

# TXT 레코드용
variable "ttl" {
  type    = number
  default = 300
}

variable "records" {
  type    = list(string)
  default = []
}
