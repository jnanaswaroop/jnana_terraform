/*==== The VPC ======*/
resource "aws_vpc" "jnanavpc" {
  cidr_block           = "208.8.8.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "jnanavpc"
    Environment = "mydevenvironment"
  }
}

/*==== Subnets ======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.jnanavpc.id}"
  tags = {
    Name        = "Jnana-igw"
    Environment = "mydevenvironment"
  }
}

/* NAT */
resource "aws_nat_gateway" "nat-gw" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.public_subnet.id
}

/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.jnanavpc.id}"
  cidr_block              = "208.8.8.0/25"
  tags = {
    Name        = "public-subnet" 
    Environment = "mydevenvironment}"
  }
}
/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.jnanavpc.id}"
  cidr_block              = "208.8.8.128/25"
  tags = {
    Name        = "private-subnet"
    Environment = "mydevenvironment}"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.jnanavpc.id}"
  tags = {
    Name        = "private-route-table"
    Environment = "mydevenvironment"
  }
}
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.jnanavpc.id}"
  tags = {
    Name        = "public-route-table"
    Environment = "mydevenvironment"
  }
}

// route tables
resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat-gw.id}"
}

/* Route table associations */
resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private.id}"
}

// Configure the EC2 instance in a public subnet
resource "aws_instance" "ec2_public" {
  count                       = 4
  ami                         = "ami-0283a57753b18025b"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "ohio"
  subnet_id                   = "${aws_subnet.public_subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.my-SG.id}"]

  tags = {
    "Name" = "Jnana-EC2-PUBLIC"
  }
}

##########################
# Security group with name
##########################
resource "aws_security_group" "my-SG" {
  name                   = "Jnana Instance SG"
  vpc_id                 = "${aws_vpc.jnanavpc.id}"
  
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
  
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }

  tags =  {
      "Name" = "Jnana Security Group"
    }
}
