variable "region" {
  description = "The AWS region to deploy resources"
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "desired_count" {
  description = "Number of desired ECS task instances"
  default     = 1
}

variable "container_port" {
  description = "Port the container listens on"
  default     = 5000
}

variable "application_name" {
  description = "Name of the application"
  default     = "flask-app"
}

variable "environment" {
  description = "Environment for deployment (e.g., development, production)"
  default     = "development"
}

variable "subnet_1_cidr" {
  description = "CIDR block for the first subnet"
  default     = "10.0.1.0/24"
}

variable "subnet_2_cidr" {
  description = "CIDR block for the second subnet"
  default     = "10.0.2.0/24"
}

variable "container_image" {
  description = "The Docker image for the application"
  default     = "kshitiz1005/weather-app:latest"
}
