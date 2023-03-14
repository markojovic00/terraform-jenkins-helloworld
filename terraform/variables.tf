variable "do_token" {}
variable "do_ssh_fingerprint" {}
variable "do_pub_key" {}
variable "do_private_key" {}

variable "region" {
  description = "Digitalocean region"
}

variable "prefix" {
  description = "Resource name prefix"
}

variable "tag" {
  description = "Environment tag"
}