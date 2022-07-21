variable "subscription_id" {
  type = string

}

variable "client_id" {
  type = string

}

variable "client_secret" {
  type = string

}

variable "tenant_id" {
  type = string

}

variable "appservicename" {
  default = "myappservice"

}

variable "location" {
  type = string

}
variable "vnetname" {
  type = string

}

variable "snet_name" {
  type = string

}
#db variables

variable "sqladmin" {
  type = string

}

variable "admpasswd" {
  type = string

}

variable "start_ip" {
  type = string
  
}

variable "end_ip" {
  type = string
  
}