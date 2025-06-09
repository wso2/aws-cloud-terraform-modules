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

locals {
  ecr_registry_url = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com"

  ci_stages = [
    {
      name = "Source"
      actions = [
        {
          name             = "Source"
          category         = "Source"
          owner            = "ThirdParty"
          provider         = "GitHub"
          version          = "1"
          output_artifacts = ["source_output"]
          configuration = {
            Owner      = var.github_org_name
            Repo       = var.ci_project_integration_build_repo_name
            Branch     = var.devops_ci_project_build_branch
            OAuthToken = var.github_personal_access_token
          }
        }
      ]
    },
    {
      name = "Prepare"
      actions = [
        {
          name             = "PrepareSource"
          category         = "Build"
          owner            = "AWS"
          provider         = "CodeBuild"
          version          = "1"
          input_artifacts  = ["source_output"]
          output_artifacts = ["prepared_source"]
          configuration = {
            ProjectName = module.buildspec_injector.aws_codebuild_project_name
          }
        }
      ]
    },
    {
      name = "Build"
      actions = [
        {
          name             = "Build"
          category         = "Build"
          owner            = "AWS"
          provider         = "CodeBuild"
          version          = "1"
          input_artifacts  = ["prepared_source"]
          output_artifacts = ["build_output"]
          configuration = {
            ProjectName = module.docker_build.aws_codebuild_project_name
          }
        }
      ]
    }
  ]

  integration_deployment_stages = [
    {
      name = "Source"
      actions = [
        {
          name             = "Source"
          category         = "Source"
          owner            = "ThirdParty"
          provider         = "GitHub"
          version          = "1"
          output_artifacts = ["source_output"]
          configuration = {
            Owner      = var.github_org_name
            Repo       = var.cd_project_integration_build_repo_name
            Branch     = var.devops_cd_project_build_branch
            OAuthToken = var.github_personal_access_token
          }
        }
      ]
    },
    {
      name = "Build"
      actions = [
        {
          name             = "Build"
          category         = "Build"
          owner            = "AWS"
          provider         = "CodeBuild"
          version          = "1"
          input_artifacts  = ["source_output"]
          output_artifacts = ["build_output"]
          configuration = {
            ProjectName = module.integration_project_build.aws_codebuild_project_name
          }
        }
      ]
    }
  ]

  common_deployment_stages = [
    {
      name = "Source"
      actions = [
        {
          name             = "Source"
          category         = "Source"
          owner            = "ThirdParty"
          provider         = "GitHub"
          version          = "1"
          output_artifacts = ["source_output"]
          configuration = {
            Owner      = var.github_org_name
            Repo       = var.cd_project_integration_build_repo_name
            Branch     = var.devops_cd_project_build_branch
            OAuthToken = var.github_personal_access_token
          }
        }
      ]
    },
    {
      name = "Build"
      actions = [
        {
          name             = "Build"
          category         = "Build"
          owner            = "AWS"
          provider         = "CodeBuild"
          version          = "1"
          input_artifacts  = ["source_output"]
          output_artifacts = ["build_output"]
          configuration = {
            ProjectName = module.cd_project_build.aws_codebuild_project_name
          }
        }
      ]
    }
  ]
}
