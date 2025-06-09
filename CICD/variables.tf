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
  type        = string
  description = "Project"
}
variable "environment" {
  type        = string
  description = "Environment"
}
variable "region" {
  type        = string
  description = "Region"
}
variable "application" {
  type        = string
  description = "Application"
}
variable "default_tags" {
  type        = map(string)
  description = "Map of default tags to apply to all resources deployed during Private Cloud deployment."
}

variable "github_personal_access_token" {
  type        = string
  description = "Github Org Personal Access Token"
}

variable "github_org_name" {
  description = "Github Org Name"
  type        = string
}

variable "ci_project_integration_build_repo_name" {
  description = "The name of the CI project IS build repo"
  type        = string
}

variable "devops_ci_project_build_branch" {
  description = "The name of the CI project build repo"
  type        = string
}

variable "ci_bucket_name" {
  description = "S3 bucket name for codepipeline"
  type        = string
  default     = "test-bucket"
}

variable "devops_ci_project_integration_build_yml_path" {
  description = "The path of the CI project IS build yml"
  type        = string
  default     = "ci-pipelines/azure-pipeline-001.yml"
}

variable "cd_project_integration_build_repo_name" {
  description = "The name of the CI project IS build repo"
  type        = string
}

variable "devops_cd_project_build_branch" {
  description = "The name of the CI project build repo"
  type        = string
}

variable "cd_bucket_name" {
  description = "S3 bucket name for codepipeline for CD"
  type        = string
  default     = "test-bucket"
}

variable "integration_bucket_name" {
  description = "S3 bucket name for codepipeline for integration"
  type        = string
  default     = "test-bucket"
}

variable "admin_role" {
  type        = string
  description = "Admin role ARN to access AWS resources."
}

variable "enable_ecr_repo_creation" {
  type        = bool
  description = "Enable ECR repository creation."
  default     = true
}

variable "buildspec_injector_path" {
  type        = string
  description = "Path to the buildspec injector file."
  default     = "buildspec_injector.yml"
}

variable "codebuild_iam_policy_path" {
  type        = string
  description = "Path to the CodeBuild IAM policy file."
  default     = "resources/codebuild-iam-policy.json"
}

variable "codepipeline_iam_policy_path" {
  type        = string
  description = "Path to the CodePipeline IAM policy file."
  default     = "resources/codepipeline-iam-policy.json"
}

variable "cd_codebuild_iam_policy_path" {
  type        = string
  description = "Path to the CD CodeBuild IAM policy file."
  default     = "resources/cd-codebuild-iam-policy.json"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name."
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID."
}
