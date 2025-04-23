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

output "cluster_name" {
  value = module.eks_cluster.eks_cluster_name
}

output "eks_cluster_issuer_url" {
  value = module.eks_cluster.eks_cluster_issuer
}

output "oidc_provider_arn" {
  value = var.create_oidc_identity_provider ? module.eks_oidc_provider[0].provider_arn : null
}

output "eks_security_group_id" {
  value = module.eks_cluster.eks_security_group_id
}