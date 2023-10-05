resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr

    tags = {
      Name = "My-VPC"      
    }
    
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id  
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr
    map_public_ip_on_launch = true
    availability_zone = "ap-southeast-1a"

    tags = {
      Name = "Public_Subnet"      
    }  
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
      Name = "Public_Route-Table"      
    }  
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public_subnet.id    
    route_table_id = aws_route_table.public_rt.id  
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr
    map_public_ip_on_launch = false
    availability_zone = "ap-southeast-1b"

    tags = {
      Name = "Private_Subnet"      
    }      
}

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.main.id

    tags = {
      Name = "Private_route"      
    }      
}

resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.private_subnet.id    
    route_table_id = aws_route_table.private_rt.id  
}

resource "aws_subnet" "database_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.database_subnet_cidr
    map_public_ip_on_launch = false
    availability_zone = "ap-southeast-1c"

    tags = {
      Name = "Database_Subnet"      
    }      
}
resource "aws_route_table" "database_rt" {
    vpc_id = aws_vpc.main.id

    tags = {
      Name = "Database_route"      
    }      
}
resource "aws_route_table_association" "database" {
    subnet_id = aws_subnet.database_subnet.id    
    route_table_id = aws_route_table.database_rt.id  
}

resource "aws_eip" "nat" {
    domain = "vpc"  
}

resource "aws_nat_gateway" "gw" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public_subnet.id  
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.gw.id
  depends_on = [aws_route_table.private_rt]
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.gw.id
  depends_on = [aws_route_table.database_rt]
}

resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}

resource "aws_instance" "server" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.webSg.id]

    tags = {
    Name = "Web-Server"
  }

}
resource "aws_s3_bucket" "my_bucket" {
    bucket = "swamy-terraform-bucket1047"  
}