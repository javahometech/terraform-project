# VPC for our applications

resource "aws_vpc" "javahome_vpc" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "JavaHomeVPC"
  }
}

# Create Internet Gateway and attach it to javahome_vpc

resource "aws_internet_gateway" "javahome_igw" {
  vpc_id = "${aws_vpc.javahome_vpc.id}"

  tags {
    Name = "main"
  }
}

# Build subnets for our VPCs
resource "aws_subnet" "public" {
  count             = "${length(var.subnets_cidr)}"
  vpc_id            = "${aws_vpc.javahome_vpc.id}"
  availability_zone = "${element(var.azs,count.index)}"
  cidr_block        = "${element(var.subnets_cidr,count.index)}"
  map_public_ip_on_launch = true
  tags {
    Name = "Subnet-${count.index +1}"
  }
}

# Create Route table, attache Internet Gateway and associate with public subnets


resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.javahome_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.javahome_igw.id}"
  }
  tags {
    Name = "PublicRT"
  }
}

# Attach route table with public subnets

resource "aws_route_table_association" "a" {
  count = "${length(var.subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_rt.id}"
}
