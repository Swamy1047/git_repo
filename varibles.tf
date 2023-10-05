variable "vpc_cidr" {
    default = "10.0.0.0/16"  
}

variable "public_subnet_cidr" {
    default = "10.0.1.0/24"  
}

variable "private_subnet_cidr" {
    default = "10.0.2.0/24"  
}

variable "database_subnet_cidr" {
    default = "10.0.3.0/24"  
}

variable "ami_id" {
    default = "ami-0df7a207adb9748c7"  
}

variable "instance_type" {
    default = "t2.micro"  
}