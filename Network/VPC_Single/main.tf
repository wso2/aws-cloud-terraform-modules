# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
#
# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#
# --------------------------------------------------------------------------------------

module "virtual_private_cloud" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/VPC?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags

  application          = "vpc"
  vpc_cidr_block       = var.vpc_cidr_range
  enable_dns_support   = true
  enable_dns_hostnames = true
}

module "internet_gateway" {
  count       = var.create_public_subnet ? 1 : 0
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Gateway?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  vpc_ids     = [module.virtual_private_cloud.vpc_id]

  application = "igw"
}

module "eip" {
  count       = var.create_public_subnet ? var.nat_redundancy ? length(module.public_subnets) : 1 : 0
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/EC2-Elastic_IP_Address?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "eip-${count.index}"
  eip_domain  = "vpc"
}

module "nat_gateways" {
  count       = var.create_public_subnet ? var.nat_redundancy ? length(module.public_subnets) : 1 : 0
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/NAT-Gateway?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "nat-${count.index}"

  allocation_id = module.eip[count.index].eip_allocation_id
  subnet_id     = module.public_subnets[count.index].subnet_id
}

module "public_subnets" {
  count  = var.create_public_subnet ? length(var.availability_zones) : 0
  source = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/VPC-Subnet?ref=UnitOfWork"

  project     = var.project
  environment = var.environment
  region      = var.region
  tags = merge(var.default_tags, {
    "public_facing" = true
  })
  vpc_id            = module.virtual_private_cloud.vpc_id
  availability_zone = var.availability_zones[count.index]

  application = "public-${count.index}"
  cidr_block  = var.public_subnets[count.index]
}

module "public_route_table" {
  count       = var.create_public_subnet ? 1 : 0
  project     = var.project
  environment = var.environment
  region      = var.region
  application = "public"
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Route-Table?ref=UnitOfWork"
  vpc_id      = module.virtual_private_cloud.vpc_id
  tags        = var.default_tags
  custom_routes = [
    {
      cidr_block = "0.0.0.0/0"
      ep_type    = "gateway_id"
      ep_id      = module.internet_gateway[0].gateway_id
    }
  ]
}

module "public_route_table_associations" {
  count          = var.create_public_subnet ? length(var.availability_zones) : 0
  source         = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Route-Table-Association?ref=UnitOfWork"
  subnet_id      = module.public_subnets[count.index].subnet_id
  route_table_id = module.public_route_table[0].route_table_id
}

module "public_security_group" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Security-Group?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  vpc_id      = module.virtual_private_cloud.vpc_id
  tags        = var.default_tags
  application = "public"
  description = "Security Group for public subnets resources"
}

module "public_security_group_egress_rules" {
  source            = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Security-Group-Egress-Rule?ref=UnitOfWork"
  security_group_id = module.public_security_group.security_group_id

  egress-rules = var.public_security_group_egress_rules
}

module "public_security_group_ingress_rules" {
  source            = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Security-Group-Ingress-Rule?ref=UnitOfWork"
  security_group_id = module.public_security_group.security_group_id
  ingress-rules     = var.public_security_group_ingress_rules
}

module "database_subnets" {
  count             = length(var.availability_zones)
  source            = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/VPC-Subnet?ref=UnitOfWork"
  project           = var.project
  environment       = var.environment
  region            = var.region
  tags              = var.default_tags
  vpc_id            = module.virtual_private_cloud.vpc_id
  availability_zone = var.availability_zones[count.index]

  application = "db-${count.index}"
  cidr_block  = var.database_subnets[count.index]
}

module "database_security_group" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Security-Group?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  vpc_id      = module.virtual_private_cloud.vpc_id

  application = "db"
  description = "Security Group for db subnets resources"
}

module "database_security_group_egress_rules" {
  source            = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Security-Group-Egress-Rule?ref=UnitOfWork"
  security_group_id = module.database_security_group.security_group_id
  egress-rules      = var.database_security_group_egress_rules
}

module "database_security_group_ingress_rules" {
  source            = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Security-Group-Ingress-Rule?ref=UnitOfWork"
  security_group_id = module.database_security_group.security_group_id
  ingress-rules = concat([
    {
      ip_protocol    = "tcp"
      from_port      = 3306
      to_port        = 3306
      security_group = module.app_security_group.security_group_id
    },
    {
      ip_protocol    = "tcp"
      from_port      = 3306
      to_port        = 3306
      security_group = module.management_security_group.security_group_id
    }
  ], var.database_security_group_ingress_rules)
}

module "app_subnets" {
  count = length(var.availability_zones)

  source            = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/VPC-Subnet?ref=UnitOfWork"
  project           = var.project
  environment       = var.environment
  region            = var.region
  tags              = var.default_tags
  vpc_id            = module.virtual_private_cloud.vpc_id
  availability_zone = var.availability_zones[count.index]

  application = "app-${count.index}"
  cidr_block  = var.app_subnets[count.index]
}

module "app_route_table" {
  count       = length(var.availability_zones)
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Route-Table?ref=UnitOfWork"
  vpc_id      = module.virtual_private_cloud.vpc_id
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "app"
  custom_routes = [
    {
      cidr_block = "0.0.0.0/0"
      ep_type    = "nat_gateway_id"
      ep_id      = var.nat_redundancy ? module.nat_gateways[count.index].nat_gateway_id : module.nat_gateways[0].nat_gateway_id
    }
  ]
}

module "app_route_table_associations" {
  count          = length(var.availability_zones)
  source         = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Route-Table-Association?ref=UnitOfWork"
  subnet_id      = module.app_subnets[count.index].subnet_id
  route_table_id = module.app_route_table[count.index].route_table_id
}

module "app_security_group" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Security-Group?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  vpc_id      = module.virtual_private_cloud.vpc_id

  application = "app"
  description = "Security Group for mgt subnets resources"
}

module "app_security_group_egress_rules" {
  source            = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Security-Group-Egress-Rule?ref=UnitOfWork"
  security_group_id = module.app_security_group.security_group_id
  egress-rules      = var.app_security_group_egress_rules
}

module "app_security_group_ingress_rules" {
  source            = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Security-Group-Ingress-Rule?ref=UnitOfWork"
  security_group_id = module.app_security_group.security_group_id
  ingress-rules = concat([
    {
      ip_protocol    = "-1"
      security_group = module.app_security_group.security_group_id
    },
    {
      ip_protocol    = "-1"
      security_group = module.public_security_group.security_group_id
    },
    {
      ip_protocol    = "-1"
      security_group = module.management_security_group.security_group_id
    }
  ], var.app_security_group_ingress_rules)
}

module "management_subnets" {
  count             = var.create_public_subnet ? length(var.availability_zones) : 0
  source            = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/VPC-Subnet?ref=UnitOfWork"
  project           = var.project
  environment       = var.environment
  region            = var.region
  tags              = var.default_tags
  vpc_id            = module.virtual_private_cloud.vpc_id
  availability_zone = var.availability_zones[count.index]

  application = "mgt-${count.index}"
  cidr_block  = var.management_subnets[count.index]
}

module "management_route_table" {
  count       = length(var.availability_zones)
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Route-Table?ref=UnitOfWork"
  vpc_id      = module.virtual_private_cloud.vpc_id
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "mgt"
  custom_routes = [
    {
      cidr_block = "0.0.0.0/0"
      ep_type    = "nat_gateway_id"
      ep_id      = var.nat_redundancy ? module.nat_gateways[count.index].nat_gateway_id : module.nat_gateways[0].nat_gateway_id
    }
  ]
}

module "management_route_table_associations" {
  count          = length(var.availability_zones)
  source         = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Route-Table-Association?ref=UnitOfWork"
  subnet_id      = module.management_subnets[count.index].subnet_id
  route_table_id = module.management_route_table[count.index].route_table_id
}

module "management_security_group" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Security-Group?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  vpc_id      = module.virtual_private_cloud.vpc_id

  application = "mgt"
  description = "Security Group for db subnets resources"
}

module "management_security_group_egress_rules" {
  source            = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Security-Group-Egress-Rule?ref=UnitOfWork"
  security_group_id = module.management_security_group.security_group_id
  egress-rules      = var.management_security_group_egress_rules
}

module "management_security_group_ingress_rules" {
  source            = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Security-Group-Ingress-Rule?ref=UnitOfWork"
  security_group_id = module.management_security_group.security_group_id
  ingress-rules     = var.management_security_group_ingress_rules
}