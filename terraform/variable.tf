
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_one_cidr" {
  description = "The CIDR block for public subnet one"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_two_cidr" {
  description = "The CIDR block for public subnet two"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_one_cidr" {
  description = "The CIDR block for private subnet one"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_two_cidr" {
  description = "The CIDR block for private subnet two"
  type        = string
  default     = "10.0.4.0/24"
}

variable "availability_zone_one" {
  description = "The first availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_two" {
  description = "The second availability zone"
  type        = string
  default     = "us-east-1b"
}

variable "my_ip" {
  description = "Your public IP address for SSH access to Bastion (format: x.x.x.x/32)"
  type        = string
  default     = "0.0.0.0/0" # CHANGE THIS to your actual IP before deploying!
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the SSH key pair to use for EC2 instances"
  type        = string
  default     = "startuptech-key"
}

