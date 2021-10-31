# nat-gateway-instance
Terraform code performs the following:
1. Creates a VPC with subnets and route tables
2. Creates a NAT Instance in one of the public subnets
3. Configures the NAT instance to support Network Address Translation
4. Creates an EC2 instance in private subnet which can access Internet though NAT instance 

## Prerequisites
1. AWS credentials
2. EIP address is available in the account

## Defaults
1. Region: eu-west-1
2. Availability Zones: eu-west-1a,eu-west-1b,eu-west-1c
3. VPC CIDR: 172.17.0.0/16

## How To
```
$ cd nat-gateway-instace/terraform
$ terraform init
$ export AWS_ACCESS_KEY_ID="<ACCESS_KEY_ID>"
$ export AWS_SECRET_ACCESS_KEY="<SECRET_ACCESS_KEY>"
$ export AWS_DEFAULT_REGION="<AWS_REGION>"
$ terraform plan -target module.vpc
$ terraform apply -target module.vpc
$ terraform plan
$ terraform apply -auto-approve
```

## Troubleshooting
To add/remove rules to the NAT instance, you can login using SSM session manager. Select the NAT instance and click "Connect" on the EC2 console. Select the tab "Session Manager" and click "Connect"

You can connect to private ec2 instance through Session Manager in the same way.