resource "aws_security_group" "bastion" {
  name = "bastion"
  description = "Allow SSH traffic from the internet"
  vpc_id = "${aws_vpc.eu-central-1.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["${var.vpc_cidr}"]
  }
}

resource "aws_security_group" "allow_access_from_bastion" {
  name = "allow-access-from-bastion"
  description = "Grants access to SSH from bastion server"
  vpc_id = "${aws_vpc.eu-central-1.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }
}

resource "aws_instance" "bastion" {
  ami = "ami-7c412f13"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.eu-central-1-public.id}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  key_name = "bastion"

  availability_zone = "eu-central-1a"

  tags {
    Name = "bastion-eu-central-1"
  }
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc = true
}