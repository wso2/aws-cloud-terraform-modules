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

variable "project" {
  type = string
}
variable "environment" {
  type = string
}
variable "region" {
  type = string
}
variable "default_tags" {
  type = map(string)
}
variable "node_group" {
  type = object({
    name                   = string
    disk_size              = number
    ssh_key_name           = string
    vpc_security_group_ids = list(string)
    eks_cluster_name       = string
    node_role_arn          = string
    subnet_ids             = list(string)
    min_size               = number
    max_size               = number
    desired_size           = number
    max_unavailable        = number
    k8s_version            = string
    instance_types         = list(string)
  })
}