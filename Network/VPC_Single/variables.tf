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

variable "availability_zones" {
  type = list(string)
}
variable "nat_redundancy" {
  type        = bool
  default     = false
  description = "Set true to create Nat gateway per each availability zone"
}
variable "create_public_subnet" {
  type        = bool
  default     = true
  description = "Set true to create public facing subnet"
}

variable "vpc_cidr_range" {
  type        = string
  description = "CIDR range for VPC"
}
variable "app_subnets" {
  type        = list(string)
  description = "List of CIDR ranges for application subnets."
}
variable "database_subnets" {
  type        = list(string)
  description = "List of CIDR ranges for database subnets."
}
variable "public_subnets" {
  type        = list(string)
  description = "List of CIDR ranges for public subnets."
  default     = []
}
variable "management_subnets" {
  type        = list(string)
  description = "List of CIDR ranges for management subnets."
}


variable "public_security_group_egress_rules" {
  type = list(object({
    ip_protocol    = string
    to_port        = optional(number)
    from_port      = optional(number)
    cidr_block     = optional(string)
    security_group = optional(string)
  }))
  default = [
    {
      ip_protocol = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  ]
}
variable "public_security_group_ingress_rules" {
  type = list(object({
    ip_protocol    = string
    to_port        = optional(number)
    from_port      = optional(number)
    cidr_block     = optional(string)
    security_group = optional(string)
  }))
  default = []
}
variable "database_security_group_egress_rules" {
  type = list(object({
    ip_protocol    = string
    to_port        = optional(number)
    from_port      = optional(number)
    cidr_block     = optional(string)
    security_group = optional(string)
  }))
  default = [
    {
      ip_protocol = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  ]
}
variable "database_security_group_ingress_rules" {
  type = list(object({
    ip_protocol    = string
    to_port        = optional(number)
    from_port      = optional(number)
    cidr_block     = optional(string)
    security_group = optional(string)
  }))
  default = []
}
variable "app_security_group_egress_rules" {
  type = list(object({
    ip_protocol    = string
    to_port        = optional(number)
    from_port      = optional(number)
    cidr_block     = optional(string)
    security_group = optional(string)
  }))
  default = [
    {
      ip_protocol = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  ]
}
variable "app_security_group_ingress_rules" {
  type = list(object({
    ip_protocol    = string
    to_port        = optional(number)
    from_port      = optional(number)
    cidr_block     = optional(string)
    security_group = optional(string)
  }))
  default = []
}
variable "management_security_group_egress_rules" {
  type = list(object({
    ip_protocol    = string
    to_port        = optional(number)
    from_port      = optional(number)
    cidr_block     = optional(string)
    security_group = optional(string)
  }))
  default = [
    {
      ip_protocol = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  ]
}
variable "management_security_group_ingress_rules" {
  type = list(object({
    ip_protocol    = string
    to_port        = optional(number)
    from_port      = optional(number)
    cidr_block     = optional(string)
    security_group = optional(string)
  }))
  default = [
    {
      ip_protocol = "-1"
      cidr_block  = "203.94.95.0/24"
    }
  ]
}