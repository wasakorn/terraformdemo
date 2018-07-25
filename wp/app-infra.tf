resource "aws_instance" "wordpress_ec2" {

  ami                         = "${var.ec2_ami}"
  instance_type               = "${var.ec2_ins_type}"
  iam_instance_profile        = "${var.ec2_ami_profile}"
  count                       = "${var.ec2_count}"
  key_name                    = "${var.ec2_key_name}"
  associate_public_ip_address = "${var.ec2_associate_public_ip_address}"
  subnet_id                   = "${aws_subnet.pub_sbn_1a.id}"
  vpc_security_group_ids      = ["${aws_security_group.ec2_sg.id}"]

   tags {
    Name                      = "${var.ec2_tag_name}"
    VPC                       = "${var.ec2_tag_vpc}"
    Purpose                   = "${var.ec2_tag_purpose}"
  }
}

resource "aws_elb" "wordpress_elb" {
  name                        = "${var.elb_name}"
  subnets                     = ["${aws_subnet.pvt_sbn_1a.id}"]
  security_groups             = ["${aws_security_group.elb_sg.id}"]
  instances                   = ["${aws_instance.wordpress_ec2.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 300
  connection_draining         = true
  connection_draining_timeout = 300
  internal                    = false

  listener {
    instance_port             = 8080
    instance_protocol         = "TCP"
    lb_port                   = 8080
    lb_protocol               = "TCP"
  }

  listener {
    instance_port             = 443
    instance_protocol         = "TCP"
    lb_port                   = 443
    lb_protocol               = "TCP"
  }

  health_check {
    healthy_threshold         = 2
    unhealthy_threshold       = 10
    timeout                   = 5
    target                    = "HTTP:8080/"
    interval                  = 30
  }
}

resource "aws_db_instance" "rds" {
  db_subnet_group_name        = "${aws_db_subnet_group.rds_sbn_grp.id}"
  vpc_security_group_ids      = ["${aws_security_group.rds_sg.id}"]
  allocated_storage           = "${var.rds_allocated_storage}"
  storage_type                = "${var.rds_storage_type}"
  engine                      = "${var.rds_engine}"
  engine_version              = "${var.rds_engine_version}"
  multi_az                    = "${var.rds_multi_az}"
  instance_class              = "${var.rds_instance_class}"
  publicly_accessible         = "${var.rds_publicly_accessible}"
  name                        = "${var.rds_name}"
  username                    = "${var.rds_username}"
  password                    = "${var.rds_password}"
  parameter_group_name        = "${var.rds_param_grp_name}"
  skip_final_snapshot         = "${var.rds_skip_final_snapshot}"
  apply_immediately           = "${var.rds_apply_immediately}"
  allow_major_version_upgrade = "${var.rds_allow_major_version_upgrade}"
  auto_minor_version_upgrade  = "${var.rds_auto_minor_version_upgrade}"
  apply_immediately           = "${var.rds_apply_immediately}"

   tags {
    Name                      = "${var.rds_tag_name}"
    VPC                       = "${var.rds_tag_vpc}"
    Purpose                   = "${var.rds_tag_purpose}"
  }
}

resource "aws_db_subnet_group" "rds_sbn_grp" {
  name                        = "${var.rds_sbn_grp_name}"
  subnet_ids                  = ["${aws_subnet.pub_sbn_1a.id}", "${aws_subnet.pub_sbn_1b.id}"]
}