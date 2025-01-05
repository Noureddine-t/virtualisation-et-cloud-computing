variable "project_id" {
  type    = string
  default = "Calculatrice Cloud Native"
}

variable "zone" {
  type    = string
  default = "fr-par-1"
}

variable "region" {
  type    = string
  default = "fr-par"
}

variable "environments" {
  type = map(string)
  default = {
    dev  = "dev"
    prod = "prod"
  }
}

variable "student" {
  type    = string
  default = "taleb"
}
