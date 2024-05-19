variable "region" {
  default = "us-west-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "private_subnet1_cidr" {
  default = "10.0.10.0/24"
}

variable "private_subnet2_cidr" {
  default = "10.0.11.0/24"
}

variable "public_subnet1_cidr" {
  default = "10.0.20.0/24"
}

variable "public_subnet2_cidr" {
  default = "10.0.21.0/24"
}
