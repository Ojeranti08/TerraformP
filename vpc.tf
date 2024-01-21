# Resource Block
# Resource-1: Create VPC
resource "aws_vpc" "ecomm-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  tags = {
    "Name" = "ecomm vpc"
  }
}

# Resource-2: Create Public Subnets
resource "aws_subnet" "ecomm-public-subnet" {
  vpc_id                  = aws_vpc.ecomm-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "ecomm public subnet1"
  }
}

# Resource-3: Create Private Subnets
resource "aws_subnet" "ecomm-private-subnet" {
  vpc_id                  = aws_vpc.ecomm-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "ecomm private subnet1"
  }
}

# Resource-4: Create Internet Gateway
resource "aws_internet_gateway" "ecomm-igw" {
  vpc_id = aws_vpc.ecomm-vpc.id
  tags = {
    Name = "ecomm igw"
  }
}

# Resource 5: Create Public Route Table
resource "aws_route_table" "ecomm-public-route-table" {
  vpc_id = aws_vpc.ecomm-vpc.id
  tags = {
    Name = "ecomm public route table"
  }
}

# Resource 6: Create Private Route Table
resource "aws_route_table" "ecomm-private-route-table" {
  vpc_id = aws_vpc.ecomm-vpc.id
  tags = {
    Name = "ecomm private route table"
  }
}

# Resource-7: Create Route in Route Table for Internet Access
resource "aws_route" "ecomm-public-route" {
  route_table_id         = aws_route_table.ecomm-public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ecomm-igw.id
}

# Resource-8: Associate the Route Table with the Public Subnet
resource "aws_route_table_association" "ecomm-public-route-table-associate" {
  route_table_id = aws_route_table.ecomm-public-route-table.id
  subnet_id      = aws_subnet.ecomm-public-subnet.id
}

# Resource-9: Associate the Route Table with the Private Subnet
resource "aws_route_table_association" "ecomm-private-route-table-associate" {
  route_table_id = aws_route_table.ecomm-private-route-table.id
  subnet_id      = aws_subnet.ecomm-private-subnet.id
}
/*
# Elastic IP for NAT Gateway
resource "aws_eip" "nat1" {
  tags = {
    Name = "eip_NAT"
  }
  depends_on = [aws_internet_gateway.ecomm-igw]
}

resource "aws_nat_gateway" "pub-nat" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.ecomm-private-subnet.id
  tags = {
    Name = "gw NAT"
  }
  depends_on = [aws_internet_gateway.ecomm-igw]
}

*/

# Resource-10: Create Security Group
resource "aws_security_group" "ecomm-sg" {
  name        = "Ecomm SSH & HTTP"
  description = "Allow SSH & HTTP inbound traffic"
  vpc_id      = aws_vpc.ecomm-vpc.id

  ingress {
    description = "Allow SSH from WWW"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP from WWW"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all IP and Ports Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Ecomm-SG"
  }
}