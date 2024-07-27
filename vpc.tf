# tcs-vpc
resource "aws_vpc" "ecom-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ecom"
  }
}
# web subnet
resource "aws_subnet" "ecom-web-sn" {
  vpc_id     = aws_vpc.ecom-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch ="true"

  tags = {
    Name = "web-sn"
  }
}
#data subnet
resource "aws_subnet" "ecom-database-sn" {
  vpc_id     = aws_vpc.ecom-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch ="false"

  tags = {
    Name = "data-sn"
  }
}
#internet gateway
resource "aws_internet_gateway" "ecom-gw" {
  vpc_id = aws_vpc.ecom-vpc.id

  tags = {
    Name = "internetgateway"
  }
}
#public route table
resource "aws_route_table" "web-route-table" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecom-gw.id
  }
    tags = {
    Name = "web-route"
  }
}
#public route table association
resource "aws_route_table_association" "web-route" {
  subnet_id      = aws_subnet.ecom-web-sn.id
  route_table_id = aws_route_table.web-route-table.id
}
#private route table
resource "aws_route_table" "database-route-table" {
  vpc_id = aws_vpc.example.id

    tags = {
    Name = "database-route"
  }
}
#private route table association
resource "aws_route_table_association" "database-route" {
  subnet_id      = aws_subnet.ecom-database-sn.id
  route_table_id = aws_route_table.database-route-table.id
}
#public nacl
resource "aws_network_acl" "web-nacl" {
  vpc_id = aws_vpc.ecom-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "public-nacl"
  }
}
#public nacl assosiaction
resource "aws_network_acl_association" "public-nacl-ass" {
  network_acl_id = aws_network_acl.web-nacl.id
  subnet_id      = aws_subnet.ecom-web-sn.id
}

#private nacl
resource "aws_network_acl" "database-nacl" {
  vpc_id = aws_vpc.ecom-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "private-nacl"
  }
}
#public nacl assosiaction
resource "aws_network_acl_association" "private-nacl-ass" {
  network_acl_id = aws_network_acl.database-nacl.id
  subnet_id      = aws_subnet.ecom-database-sn.id
}

#public security group
resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.ecom-vpc.id

  tags = {
    Name = "web-sg"
  }
}
#public sequrity group ingress rules
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.web-sg.id
  cidr_ipv4         = 0.0.0./0
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web-sg.id
  cidr_ipv4         = 0.0.0./0
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
### public sequrity group egress rule 
# --> by defaultly aws creates allow all egressrule 
# --> so no need to create egress rule manually.
