variable "app_name" {
  default = "finance-app"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "container_image" {
  default = "nginx:latest"
}

variable "container_port" {
  default = 80
}

variable "cpu" {
  default = 256
}

variable "memory" {
  default = 512
}

variable "desired_count" {
  default = 1
}

variable "environment" {
  default = "dev"
}