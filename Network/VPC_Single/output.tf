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

output "vpc_id" {
  value = module.virtual_private_cloud.vpc_id
}

output "app_subnets_id" {
  value = module.app_subnets[*].subnet_id
}
output "database_subnets_id" {
  value = module.database_subnets[*].subnet_id
}
output "public_subnets_id" {
  value = module.public_subnets[*].subnet_id
}
output "management_subnets_id" {
  value = module.management_subnets[*].subnet_id
}

output "app_security_group_id" {
  value = module.app_security_group.security_group_id
}
output "public_security_group_id" {
  value = module.public_security_group.security_group_id
}
output "management_security_group_id" {
  value = module.management_security_group.security_group_id
}
output "database_security_group_id" {
  value = module.database_security_group.security_group_id
}


