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

module "launch_template" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/EC2-Launch-Template?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags

  application            = var.node_group.name
  disk_size              = var.node_group.disk_size
  ssh_key_name           = var.node_group.ssh_key_name
  vpc_security_group_ids = var.node_group.vpc_security_group_ids
}

module "app_node_group" {
  source = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/EKS-Node-Group?ref=UnitOfWork"
  tags   = var.default_tags

  eks_cluster_name   = var.node_group.eks_cluster_name
  node_group_name    = var.node_group.name
  node_role_arn      = var.node_group.node_role_arn
  subnet_ids         = var.node_group.subnet_ids
  min_size           = var.node_group.min_size
  max_size           = var.node_group.max_size
  desired_size       = var.node_group.desired_size
  max_unavailable    = var.node_group.max_unavailable
  k8s_version        = var.node_group.k8s_version
  instance_types     = var.node_group.instance_types
  launch_template_id = module.launch_template.launch_template_id
}