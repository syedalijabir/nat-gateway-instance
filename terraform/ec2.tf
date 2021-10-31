resource "random_integer" "random_private_subnet" {
  min = 0
  max = length(module.vpc.private_subnets)-1
}

resource "aws_instance" "private_instance" {
  ami           = data.aws_ssm_parameter.amazon_linux_ami.value
  instance_type = "t3.micro"

  # Pick any private subnet
  subnet_id = module.vpc.private_subnets[random_integer.random_private_subnet.result]

  iam_instance_profile   = aws_iam_instance_profile.private_instance_profile.name
  vpc_security_group_ids = [aws_security_group.allow_nat_access_sg.id, aws_security_group.allow_ssh_from_nat.id]
  user_data              = data.template_file.private_user_data.rendered

  #  key_name = "<EXISTING_KEY_NAME>"

  tags = {
    Name       = "${var.stack_prefix}-Private-Instance"
    controller = "terraform"
    stack      = "${var.stack_prefix}-private-instance"
  }
}

resource "aws_iam_instance_profile" "private_instance_profile" {
  name = "${var.stack_prefix}-private-instance-profile"
  role = aws_iam_role.private_instance_role.name
}

resource "aws_iam_role" "private_instance_role" {
  name = "${var.stack_prefix}-private-instance-role"
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

resource "aws_iam_policy_attachment" "private_ssm_policy" {
  name       = "${var.stack_prefix}-private-ssm-policy-attachment"
  roles      = [aws_iam_role.private_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

