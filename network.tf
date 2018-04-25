# Create a VPC to launch our instances into
resource "aws_vpc" "eu-central-1" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "our-vpc"
  }
}

resource "aws_internet_gateway" "eu-central-1" {
  vpc_id = "${aws_vpc.eu-central-1.id}"
}

resource "aws_nat_gateway" "eu-central-1" {
  subnet_id = "${aws_subnet.eu-central-1-public.id}"
  allocation_id = "${aws_eip.nat.id}"

  depends_on = ["aws_internet_gateway.eu-central-1"]

  count = 1
}

resource "aws_eip" "nat" {
  vpc = true
}

# Public subnet
resource "aws_subnet" "eu-central-1-public" {
  vpc_id = "${aws_vpc.eu-central-1.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "eu-central-1a"

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table" "eu-central-1-public" {
  vpc_id = "${aws_vpc.eu-central-1.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.eu-central-1.id}"
  }

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_route_table_association" "eu-central-1-public" {
    subnet_id = "${aws_subnet.eu-central-1-public.id}"
    route_table_id = "${aws_route_table.eu-central-1-public.id}"
}

# Private subnet
resource "aws_subnet" "eu-central-1-private" {
  vpc_id = "${aws_vpc.eu-central-1.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "eu-central-1a"

  tags {
    Name = "Private Subnet"
  }
}

resource "aws_route_table" "eu-central-1-private" {
    vpc_id = "${aws_vpc.eu-central-1.id}"

    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = "${aws_nat_gateway.eu-central-1.id}"
    }

    tags {
        Name = "Private Subnet"
    }
}

resource "aws_route_table_association" "eu-west-1a-private" {
    subnet_id = "${aws_subnet.eu-central-1-private.id}"
    route_table_id = "${aws_route_table.eu-central-1-private.id}"
}


