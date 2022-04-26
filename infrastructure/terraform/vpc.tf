resource "aws_vpc" "cecs" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Owner = "anro"
  }
}

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

#################################
# Configure public subnet
#################################
resource "aws_subnet" "public_subnet_cecs" {
  vpc_id                  = aws_vpc.cecs.id
  cidr_block              = "192.168.0.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = "true"
  tags = {
    Owner = "anro"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.cecs.id
  tags = {
    Owner = "anro"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.cecs.id
  tags = {
    Owner = "anro"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet_cecs.id
  route_table_id = aws_route_table.public.id
}


#################################
# Configure private subnet
#################################
resource "aws_subnet" "private_subnet_cecs" {
  vpc_id                  = aws_vpc.cecs.id
  cidr_block              = "192.168.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = "false"
  tags = {
    Owner = "anro"
  }
}

resource "aws_eip" "nat_eip" {
  vpc        = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_cecs.id
  tags = {
    Owner = "anro"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.cecs.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "instance" {
  subnet_id = aws_subnet.private_subnet_cecs.id
  route_table_id = aws_route_table.private.id
}

#################################
#VPC's Default Security Group
#################################
resource "aws_security_group" "cecs_sg" {
  name        = "cecs-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.cecs.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
  }

    ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 443
    to_port = 443
    protocol = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 8474
    to_port = 8474
    protocol = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 9999
    to_port = 9999
    protocol = "tcp"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Owner = "anro"
  }
}


