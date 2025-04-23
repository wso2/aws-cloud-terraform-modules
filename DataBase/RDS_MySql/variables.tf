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
variable "application" {
  type = string
}
variable "default_tags" {
  type = map(string)
}

variable "db_subnet_ids" {
  type        = list(string)
  description = "List of subnet ids to associate with DB subnet group"
}
variable "instance_class" {
  type        = string
  description = "DB instance class"
}
variable "username" {
  type        = string
  description = "User name for DB instance"
}
variable "engine_version" {
  type        = string
  description = "DB engin version"
}
variable "require_tls" {
  type        = bool
  description = "set true, to enable TLS required for DB communication"
}
variable "deletion_protection" {
  type        = bool
  default     = true
  description = "Set false to disable deletion protection"
}
variable "create_db_proxy" {
  type        = bool
  default     = false
  description = "Set true to create DB proxy resource"
}
variable "db_proxy_role_arn" {
  type        = string
  default     = null
  description = "IAM role arn to use with DB proxy"
}
variable "multi_az" {
  type        = bool
  default     = false
  description = "Set true, to create DB with multi-az distribution"
}
variable "db_security_group_ids" {
  type        = list(string)
  description = "List of security groups ids to attache to DB instance"
}
variable "proxy_auth_list" {
  type = list(object({
  }))
  default     = []
  description = "List of secret arns to use by DB proxy to access database"
}
