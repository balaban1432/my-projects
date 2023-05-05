resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "terraform-vpc-${var.owner}"
  }
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet1_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-public-1a-${var.owner}"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet2_cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-public-1b-${var.owner}"
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet1_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "terraform-private-1a-${var.owner}"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet2_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = "terraform-private-1b-${var.owner}"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "terraform-igw-${var.owner}"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "terraform-public-rt-${var.owner}"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main.id


  tags = {
    Name = "terraform-private-rt-${var.owner}"
  }
}


resource "aws_route_table_association" "public-1a" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-2a" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-1a" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-2a" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private-rt.id
}
