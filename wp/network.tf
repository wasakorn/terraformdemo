resource "aws_vpc" "wordpress" {
  cidr_block                = "${var.vpc_cidr}"
  enable_dns_support        = true
  enable_dns_hostnames      = true

   tags {
    Name                    = "${var.vpc_tag_name}"
    VPC                     = "${var.vpc_tag_vpc}"
    Purpose                 = "${var.vpc_tag_purpose}"
  }
}

resource "aws_subnet" "pub_sbn_1a" {
  vpc_id                    = "${aws_vpc.wordpress.id}"
  cidr_block                = "${var.pub_sbn_1a_cidr}"
  map_public_ip_on_launch   = true
  availability_zone         = "ap-southeast-1a"

  tags {
    Name                    = "Pub-Subnet-1a"
  }
}

resource "aws_subnet" "pub_sbn_1b" {
  vpc_id                    = "${aws_vpc.wordpress.id}"
  cidr_block                = "${var.pub_sbn_1b_cidr}"
  map_public_ip_on_launch   = true
  availability_zone         = "ap-southeast-1b"

  tags {
    Name                    = "Pub-Subnet-1b"
  }
}

resource "aws_subnet" "pub_sbn_1c" {
  vpc_id                    = "${aws_vpc.wordpress.id}"
  cidr_block                = "${var.pub_sbn_1c_cidr}"
  map_public_ip_on_launch   = true
  availability_zone         = "ap-southeast-1c"

  tags {
    Name                    = "Pub-Subnet-1c"
  }
}

resource "aws_subnet" "pvt_sbn_1a" {
  vpc_id                    = "${aws_vpc.wordpress.id}"
  cidr_block                = "${var.pvt_sbn_1a_cidr}"
  map_public_ip_on_launch   = true
  availability_zone         = "ap-southeast-1a"

  tags {
    Name                    = "Pvt-Subnet-1a"
  }
}

resource "aws_subnet" "pvt_sbn_1b" {
  vpc_id                    = "${aws_vpc.wordpress.id}"
  cidr_block                = "${var.pvt_sbn_1b_cidr}"
  map_public_ip_on_launch   = true
  availability_zone         = "ap-southeast-1b"

  tags {
    Name                    = "Pvt-Subnet-1b"
  }
}

resource "aws_subnet" "pvt_sbn_1c" {
  vpc_id                    = "${aws_vpc.wordpress.id}"
  cidr_block                = "${var.pvt_sbn_1c_cidr}"
  map_public_ip_on_launch   = true
  availability_zone         = "ap-southeast-1c"

  tags {
    Name                    = "Pvt-Subnet-1c"
  }
}

resource "aws_eip" "nat_gw_ip" {
  vpc                       = true
}

resource "aws_nat_gateway" "nat_gw" {
allocation_id               = "${aws_eip.nat_gw_ip.id}"
subnet_id                   = "${aws_subnet.pub_sbn_1a.id}"
depends_on                  = ["aws_internet_gateway.igw"]

  tags {
    Name                    = "${var.nat_tag_name}"
    VPC                     = "${var.nat_tag_vpc}"
    Purpose                 = "${var.nat_tag_purpose}"
  }
}


resource "aws_route" "pvt_route" {
  route_table_id            = "${aws_route_table.pvt_table.id}"
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = "${aws_nat_gateway.nat_gw.id}"
}


resource "aws_route_table" "pvt_table" {
  vpc_id                    = "${aws_vpc.wordpress.id}"

  tags {
    Name                    = "${var.pvt_tbl_tag_name}"
    VPC                     = "${var.pvt_tbl_tag_vpc}"
    Purpose                 = "${var.pvt_tbl_tag_purpose}"
  }
}

resource "aws_route_table" "pub_table" {
  vpc_id                    = "${aws_vpc.wordpress.id}"

  tags {
    Name                    = "${var.pub_tbl_tag_name}"
    VPC                     = "${var.pub_tbl_tag_vpc}"
    Purpose                 = "${var.pub_tbl_tag_purpose}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id                    = "${aws_vpc.wordpress.id}"

  tags {
    Name                    = "${var.igw_tag_name}"
    VPC                     = "${var.igw_tag_vpc}"
    Purpose                 = "${var.igw_tag_purpose}"
  }
}

resource "aws_route" "pub_route" {
  route_table_id            = "${aws_route_table.pub_table.id}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = "${aws_internet_gateway.igw.id}"
}

resource "aws_route_table_association" "pub_sbn_1a_association" {
    subnet_id               = "${aws_subnet.pub_sbn_1a.id}"
    route_table_id          = "${aws_route_table.pub_table.id}"
}
resource "aws_route_table_association" "pub_sbn_1b_association" {
    subnet_id               = "${aws_subnet.pub_sbn_1b.id}"
    route_table_id          = "${aws_route_table.pub_table.id}"
}
resource "aws_route_table_association" "pub_sbn_1c_association" {
    subnet_id               = "${aws_subnet.pub_sbn_1c.id}"
    route_table_id          = "${aws_route_table.pub_table.id}"
}

resource "aws_route_table_association" "pvt_sbn_1a_association" {
  subnet_id                 = "${aws_subnet.pvt_sbn_1a.id}"
  route_table_id            = "${aws_route_table.pvt_table.id}"
}

resource "aws_route_table_association" "pvt_sbn_1b_association" {
  subnet_id                 = "${aws_subnet.pvt_sbn_1b.id}"
  route_table_id            = "${aws_route_table.pvt_table.id}"
}

resource "aws_route_table_association" "pvt_sbn_1c_association" {
  subnet_id                 = "${aws_subnet.pvt_sbn_1c.id}"
  route_table_id            = "${aws_route_table.pvt_table.id}"
}

data "aws_caller_identity" "current" {}

resource "aws_vpc_peering_connection" "newtoexisting" {
  peer_owner_id             = "${data.aws_caller_identity.current.account_id}"
  peer_vpc_id               = "${var.vpc_to_peer}"
  vpc_id                    = "${aws_vpc.wordpress.id}"
  auto_accept               = true
}

resource "aws_route" "peeringroutea" {
  route_table_id            = "${var.peer_route_table}"
  destination_cidr_block    = "${var.vpc_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.newtoexisting.id}"
}

resource "aws_route" "peeringrouteb" {
  route_table_id            = "${aws_route_table.pub_table.id}"
  destination_cidr_block    = "${var.vpc_to_route_cidr}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.newtoexisting.id}"
}

