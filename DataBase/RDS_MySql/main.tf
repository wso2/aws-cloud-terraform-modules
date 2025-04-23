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

module "db_subnet_group" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/RDS-Subnet-Group?ref=UnitOfWork"
  project     = lower(var.project)
  environment = lower(var.environment)
  region      = var.region
  tags        = var.default_tags
  application = var.application
  subnet_ids  = var.db_subnet_ids
}

resource "random_string" "random" {
  length  = 4
  lower   = true
  special = false
}

module "mysql_db" {
  source                           = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/RDS?ref=UnitOfWork"
  project                          = lower(var.project)
  environment                      = lower(var.environment)
  region                           = var.region
  application                      = var.application
  tags                             = var.default_tags
  username                         = var.username
  engine                           = "mysql"
  engine_version                   = var.engine_version
  instance_class                   = var.instance_class
  final_snapshot_identifier_suffix = random_string.random.result
  multi_az                         = var.multi_az

  vpc_security_group_ids = var.db_security_group_ids
  db_subnet_group_name   = module.db_subnet_group.subnet_group_name
  deletion_protection    = var.deletion_protection
}

module "mysql_db_proxy" {
  count = var.create_db_proxy ? 1 : 0

  source                 = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/RDS-Proxy?ref=UnitOfWork"
  project                = lower(var.project)
  environment            = lower(var.environment)
  region                 = var.region
  application            = var.application
  tags                   = var.default_tags
  engine                 = "MYSQL"
  require_tls            = var.require_tls
  vpc_security_group_ids = var.db_security_group_ids
  vpc_subnets            = var.db_subnet_ids
  role_arn               = var.db_proxy_role_arn
  auth_list              = var.proxy_auth_list
}

module "mysql_db_proxy_target" {
  count = var.create_db_proxy ? 1 : 0

  source                    = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/RDS-Proxy-Target-Group?ref=UnitOfWork"
  db_instance_identifier    = module.mysql_db.db_identifier
  db_proxy_name             = module.mysql_db_proxy[0].db_proxy_name
  default_target_group_name = module.mysql_db_proxy[0].default_target_group_name
}