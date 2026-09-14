variable "project_name" {

  type = string

  default = "employee-management"
}


variable "region" {

  type = string

  default = "us-east-1"
}


variable "instance_type" {

  type = string

  default = "t3.micro"
}


variable "key_pair" {

  description = "Existing EC2 key pair name"

  type = string
}


variable "db_name" {

  type = string

  default = "employee_db"
}


variable "db_user" {

  type = string

  default = "employee_admin"
}


variable "db_password" {

  type = string

  sensitive = true
}
