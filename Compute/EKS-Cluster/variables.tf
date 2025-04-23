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
variable "k8s_version" {
  type = string
}
variable "eks_public_access_cidrs" {
  type = list(string)
}
variable "cluster_subnet_ids" {
  type = list(string)
}

variable "eks_service_ipv4_cidr" {
  type        = string
  default     = "172.20.0.0/16"
  description = "private ipv4 address ranger for eks services"
}

variable "authentication_mode" {
  type        = string
  default     = "API_AND_CONFIG_MAP"
  description = "The authentication mode for the cluster. Valid values are CONFIG_MAP, API or API_AND_CONFIG_MAP"
}

variable "eks_endpoint_public_access" {
  type        = bool
  default     = false
  description = "Whether the Amazon EKS public API server endpoint is enabled. Default is true"
}

variable "eks_security_group_egress_rules" {
  type = list(object({
    ip_protocol    = string
    to_port        = optional(number)
    from_port      = optional(number)
    cidr_block     = optional(string)
    security_group = optional(string)
  }))
  default     = []
  description = "Egress rules for EKS control plane security group"
}

variable "eks_security_group_ingress_rules" {
  type = list(object({
    ip_protocol    = string
    to_port        = optional(number)
    from_port      = optional(number)
    cidr_block     = optional(string)
    security_group = optional(string)
  }))
  default     = []
  description = "Ingress rules for EKS control plane security group"
}

variable "access_entry" {
  type = list(object({
    principal_arn = string
    policy_arn    = string
    type          = string
  }))
  default     = []
  description = "List of access entires to add to EKS allowing IAM user/role access."
}

variable "create_oidc_identity_provider" {
  type        = bool
  default     = true
  description = "Create oidc identity provider to use with EKS IRSA"
}