data "aws_vpc" "selected" {
  id = "vpc-07d0182d76c7ee6cf"
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name = "tag:Purpose"
    values = ["infra"]
  }
  
}

module "vpn_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "vpn-server"
  description = "Security group for open vpn server"
  vpc_id      = data.aws_vpc.selected.id

  ingress_cidr_blocks      = ["115.97.32.118/32"]
  ingress_rules            = ["ssh-tcp"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 943
      to_port     = 943
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "115.97.32.118/32"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "115.97.32.118/32"
    }
  ]

  egress_rules = ["all-all"]
}


module "vpn_ec2" {
  source              = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "openvpn-instance"

  ami                    = "ami-037ff6453f0855c46"
  instance_type          = "t2.micro"
  key_name               = "office-mac-ssh-key"

  vpc_security_group_ids = [module.vpn_server_sg.security_group_id]
  subnet_id              = data.aws_subnets.private.ids[0]
  associate_public_ip_address = true
}

output "vpn_ec2" {
  value = module.vpn_ec2.public_ip
}