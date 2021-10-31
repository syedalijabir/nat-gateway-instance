resource "aws_eip" "nat_instance_eip" {
  instance = aws_instance.nat_instance.id
  vpc      = true
}

resource "random_integer" "random_public_subnet" {
  min = 0
  max = length(module.vpc.public_subnets)-1
}

resource "aws_instance" "nat_instance" {
  ami           = data.aws_ssm_parameter.amazon_linux_ami.value
  instance_type = "t3.micro"

  subnet_id                   = module.vpc.public_subnets[random_integer.random_public_subnet.result]
  source_dest_check           = false
  associate_public_ip_address = true

  iam_instance_profile   = aws_iam_instance_profile.nat_instance_profile.name
  vpc_security_group_ids = [aws_security_group.nat_instance_sg.id]
  user_data              = data.template_file.nat_user_data.rendered

  #  key_name = "<EXISTING_KEY_NAME>"

  tags = {
    Name       = "${var.stack_prefix}-Nat-Instance"
    controller = "terraform"
    stack      = "${var.stack_prefix}-nat-instance"
  }
}

resource "aws_iam_instance_profile" "nat_instance_profile" {
  name = "${var.stack_prefix}-nat-instance-profile"
  role = aws_iam_role.nat_instance_role.name
}

resource "aws_iam_role" "nat_instance_role" {
  name = "${var.stack_prefix}-nat-instance-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "ssm_policy" {
  name       = "${var.stack_prefix}-ssm-policy-attachment"
  roles      = [aws_iam_role.nat_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "nat_instance_sg" {
  name        = "${var.stack_prefix}-nat-instance-sg"
  description = "SG for NAT instance"
  vpc_id      = module.vpc.vpc_id

  ingress = [
    {
      description      = "Allow all traffic from private subnets"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      security_groups  = [aws_security_group.allow_nat_access_sg.id]
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    },
    {
      description      = "Allow SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      security_groups  = []
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    }
  ]
  egress = [
    {
      description      = "Allow all egress"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      security_groups  = []
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    }
  ]

  tags = {
    Name       = "${var.stack_prefix}-nat-instance-sg"
    controller = "terraform"
  }
}

resource "aws_security_group" "allow_nat_access_sg" {
  name        = "${var.stack_prefix}-allow-nat-access-sg"
  description = "SG to allow public access for private instances"
  vpc_id      = module.vpc.vpc_id

  egress = [
    {
      description      = "Allow all egress"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      security_groups  = []
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    }
  ]

  tags = {
    Name       = "${var.stack_prefix}-allow-nat-access-sg"
    controller = "terraform"
  }
}

resource "aws_route" "nat_route" {
  depends_on             = [module.vpc]
  for_each               = toset(module.vpc.private_route_table_ids)
  route_table_id         = each.key
  destination_cidr_block = "0.0.0.0/0"
  instance_id            = data.aws_instance.nat_instance.id
}

resource "aws_security_group" "allow_ssh_from_nat" {
  name   = "${var.stack_prefix}-allow-ssh-from-nat-sg"
  vpc_id = module.vpc.vpc_id

  ingress = [
    {
      description      = "Allow SSH from NAT instance"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      security_groups  = [aws_security_group.nat_instance_sg.id]
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
    },
    {
      description      = "Allow ping"
      from_port        = -1
      to_port          = -1
      protocol         = "icmp"
      security_groups  = [aws_security_group.nat_instance_sg.id]
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = true
    }
  ]

  tags = {
    Name       = "${var.stack_prefix}-allow-ssh-from-nat-sg"
    controller = "terraform"
  }
}
