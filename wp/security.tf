resource "aws_security_group" "ec2_sg" {
  name          = "${var.ec2_sg_name}" 
  description   = "Allow access to the Wordpress EC2."
  vpc_id        = "${aws_vpc.wordpress.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["${var.ec2_sg_ing_cidr}"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks =  ["${var.elb_sg_http_ing_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.ec2_sg_tag_name}"
    VPC         = "${var.ec2_sg_tag_vpc}"
    Purpose     = "${var.ec2_sg_tag_purpose}"
  }
}

resource "aws_security_group" "elb_sg" {
  name          = "${var.elb_sg_name}" 
  description   = "Allow access to the Wordpress ELB."
  vpc_id        = "${aws_vpc.wordpress.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["${var.elb_sg_http_ing_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.elb_sg_tag_name}"
    VPC         = "${var.elb_sg_tag_vpc}"
    Purpose     = "${var.elb_sg_tag_purpose}"
  }
}

resource "aws_security_group" "rds_sg" {
  name          = "${var.rds_sg_name}" 
  description   = "Allow access to the Wordpress RDS Wordpress."
  vpc_id        = "${aws_vpc.wordpress.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = ["${var.rds_sg_cnc_ing_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.rds_sg_tag_name}"
    VPC         = "${var.rds_sg_tag_vpc}"
    Purpose     = "${var.rds_sg_tag_purpose}"
  }
}