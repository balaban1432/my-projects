
#create vpc
resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "${var.project_name}_vpc"
  }
}

# create igw
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.project_name}_igw"
  }
}


# create subnets - Note: for public subnet we provide auto assign IP setting as enabled.
resource "aws_subnet" "public_1a_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.az_a
  map_public_ip_on_launch = "true" #auto assign IP setting as enabled.

  tags = {
    Name = "${var.project_name}_public_1a_subnet"
  }
}


resource "aws_subnet" "private_1a_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.az_a


  tags = {
    Name = "${var.project_name}_private_1a_subnet"
  }
}

resource "aws_subnet" "public_1b_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = var.az_b
  map_public_ip_on_launch = "true" #auto assign IP setting as enabled.

  tags = {
    Name = "${var.project_name}_public_1b_subnet"
  }
}
resource "aws_subnet" "private_1b_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = var.az_b

  tags = {
    Name = "${var.project_name}_private_1b_subnet"
  }
}



# create public route table and add routes 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "${var.project_name}_public_rt"
  }
}


#create private route table and add routes 
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.project_name}_private_rt"
  }
}


#create vpc s3 enspoint abd connect to private rt 
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.my_vpc.id
  service_name = "com.amazonaws.us-east-1.s3"
  route_table_ids = [aws_route_table.private_rt.id]

  tags = {
    Name= "${var.project_name}_vpc_s3_enpt"
  }
}

#create nat instance
resource "aws_instance" "nat" {
  ami           = var.nat_instance_ami
  instance_type = var.instance_type
  #subnet_id     = aws_subnet.public_1a_subnet.id
  #vpc_security_group_ids = [aws_security_group.nat.id]
  key_name      = var.key_name
  tags = {
    Name =  "${var.project_name}_nat_instance"
  }

  lifecycle {
    create_before_destroy = true
  }

  network_interface {
    network_interface_id = aws_network_interface.nat.id
    device_index         = 0
  }
}


#create network-interface for nat instance
resource "aws_network_interface" "nat" {
  subnet_id   = aws_subnet.public_1a_subnet.id
  private_ips = ["10.0.1.10"]
  security_groups = [aws_security_group.nat.id]
  source_dest_check = false
  tags = {
    Name = "${var.project_name}_nat-nic"
  }
}

#add route for nat instace to private rt
resource "aws_route" "r" {
  route_table_id            = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id  = aws_network_interface.nat.id
}

#create route table assosiations
resource "aws_route_table_association" "private1a" {
  subnet_id      = aws_subnet.private_1a_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private1b" {
  subnet_id      = aws_subnet.private_1b_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "public1a" {
  subnet_id      = aws_subnet.public_1a_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public1b" {
  subnet_id      = aws_subnet.public_1b_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

#create db subnet group

resource "aws_db_subnet_group" "dbsubnetgrp" {
  name       = "${var.project_name}_db_subnet_grp"
  subnet_ids = [aws_subnet.private_1a_subnet.id, aws_subnet.private_1b_subnet.id]

}