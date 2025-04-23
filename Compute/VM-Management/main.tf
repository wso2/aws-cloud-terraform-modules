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

module "instance-connect-endpoint" {
  source                      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/EC2-Connect-VPC-Endpoint?ref=UnitOfWork"
  project                     = var.project
  environment                 = var.environment
  region                      = var.region
  tags                        = var.default_tags
  application                 = var.application
  endpoint_security_group_ids = var.security_group_ids
  subnet_id                   = var.subnet_id
}

module "iam_instance_role" {
  count         = var.iam_role_name == null ? 0 : 1
  source        = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Instance-Profile?ref=UnitOfWork"
  project       = var.project
  environment   = var.environment
  region        = var.region
  tags          = var.default_tags
  application   = var.application
  iam_role_name = var.iam_role_name
}

module "management_vm" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/EC2-Instance?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags

  application               = var.application
  subnet_id                 = var.subnet_id
  ec2_ami                   = var.ami_id
  ec2_instance_type         = var.ec2_instance_type
  vpc_security_group_ids    = var.security_group_ids
  root_volume_size          = var.root_volume_size
  encrypt_root_volume       = true
  iam_instance_profile_name = var.iam_role_name == null ? null : module.iam_instance_role[0].ec2-instance-profile-name
  ssh_key_name              = var.ssh_key_name
}