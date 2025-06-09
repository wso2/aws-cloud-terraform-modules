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

module "docker_build" {
  source             = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Code-Build?ref=UnitOfWork"
  description        = "CI project to build Docker image"
  project            = var.project
  build_name         = "docker"
  codebuild_role_arn = module.codebuild_role.iam_role_arn
  environment_variables = [
    {
      name  = "ECR_REGISTRY_URL"
      value = local.ecr_registry_url
    }
  ]
  tags = var.default_tags
}

module "buildspec_injector" {
  source             = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Code-Build?ref=UnitOfWork"
  description        = "CI project to build Docker image"
  project            = var.project
  build_name         = "buildspec_injector"
  codebuild_role_arn = module.codebuild_role.iam_role_arn
  environment_variables = [
    {
      name  = "GITHUB_TOKEN"
      value = var.github_personal_access_token
    }
  ]
  codebuild_source = {
    type      = "CODEPIPELINE"
    buildspec = file(var.buildspec_injector_path)
  }
  tags = var.default_tags
}

module "ci_s3_bucket" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/S3-Account?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  application = var.ci_bucket_name
  tags        = var.default_tags
}

module "ci_pipeline" {
  source               = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Code-Pipeline?ref=UnitOfWork"
  pipeline_name        = "ci"
  project              = var.project
  pipeline_role_arn    = module.codepipeline_role.iam_role_arn
  stages               = local.ci_stages
  artifact_bucket_name = join("-", [var.project, var.ci_bucket_name, var.environment, var.region, "bucket"])
  tags                 = var.default_tags
}
