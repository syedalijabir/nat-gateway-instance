data "aws_ssm_parameter" "amazon_linux_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "template_file" "nat_user_data" {
  template = file("files/nat-user-data.sh.tpl")
  vars = {
    region   = var.region
    vpc_cidr = var.vpc_cidr
  }
}

data "template_file" "private_user_data" {
  template = file("files/private-user-data.sh.tpl")
  vars = {
    region = var.region
  }
}

data "aws_instance" "nat_instance" {
  depends_on = [aws_instance.nat_instance]
  filter {
    name   = "tag:Name"
    values = ["${var.stack_prefix}-Nat-Instance"]
  }
}
