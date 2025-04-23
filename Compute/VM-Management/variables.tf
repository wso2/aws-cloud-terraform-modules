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
variable "application" {
  type = string
}
variable "ami_id" {
  type        = string
  description = "AMI id used to crate VM"
}
variable "ec2_instance_type" {
  type        = string
  default     = "t3a.nano"
  description = "VM type to use with"
}
variable "ssh_key_name" {
  type        = string
  default     = null
  description = "SSH key use with SSH access"
}
variable "root_volume_size" {
  type        = number
  default     = 20
  description = "Root volume size in GB to create"
}
variable "security_group_ids" {
  type        = list(string)
  description = "List of security group ids to attached to the VM NIC"
}
variable "iam_role_name" {
  type        = string
  default     = null
  description = "IAM role to use with the vm instance profile"
}
variable "subnet_id" {
  type        = string
  description = "The subnet used to deploy VM"
}