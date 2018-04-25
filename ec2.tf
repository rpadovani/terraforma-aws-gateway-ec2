# We can access the server only through SSH and the NLB
resource "aws_security_group" "ec2_instance" {
  name        = "ec2_instance"
  description = "Access only through ssh"

  vpc_id = "${aws_vpc.eu-central-1.id}"

  tags {
    Name = "Security group for ur EC2 instance with our software"
  }
}

resource "aws_security_group_rule" "http_access_only_nlb" {
  type = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  # TODO: waiting https://github.com/terraform-providers/terraform-provider-aws/pull/2901
  # cidr_blocks = ["${aws_lb.our_nlb.dns_name}"]
  cidr_blocks = ["${var.vpc_cidr}"]

  security_group_id = "${aws_security_group.ec2_instance.id}"
}

resource "aws_security_group_rule" "outbound_all" {
  type = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.ec2_instance.id}"
}

# The latest Ubuntu 16.04
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

# We create a custom EC2 instance to run our application, using Ubuntu
resource "aws_instance" "aws_instance" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.medium"

  tags {
    Name = "OurInference"
  }

  key_name = "terraform"
  availability_zone = "eu-central-1a"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.ec2_instance.id}", "${aws_security_group.allow_access_from_bastion.id}"]
  subnet_id = "${aws_subnet.eu-central-1-private.id}"
}