# nat-gateway-instance
CloudFormation template to create a NAT instance in a single AZ

## Prerequisites
1. VPC exists with atleast one private and public subnet
2. Internet GW exists
3. EIP address is available in the account


## How To
The CFN Template sets up the NAT Instance and the related resources and associations.

1. Go to CloudFormation UI and upload the template with required input parameters to create a stack <STACK_NAME>

### Inputs
  VpcId: VpcId Id

  VpcCidr: Vpc CIDR

  PrivateSubnetId: ID of private subnet

  PublicSubnetId: ID of public subnet

  InternetGatewayId: ID of Internet Gateway

  AmazonLinux2AmiId: Automatically fetched from Parameter Store (do not change)

Note: Provide Subnet IDs of the same AZ

2. Create a private EC2 instance without any public internet access

3. In order to provide access to internet, attach the private EC2 instance with SG named <STACK_NAME>-AllowNatAccessSecurityGroup-*

## Troubleshooting
To add/remove rules to the NAT instance, you can login using SSM session manager. Select the NAT instance and click "Connect" on the EC2 console. Select the tab "Session Manager" and click "Connect"