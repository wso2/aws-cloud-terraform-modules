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

module "cd_common_s3_bucket" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/S3-Account?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  application = var.cd_bucket_name
  tags        = var.default_tags
}

module "cd_project_build" {
  source             = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Code-Build?ref=UnitOfWork"
  project            = var.project
  description        = "CD project to build common artifacts for Kubernetes deployment"
  build_name         = "common-k8s-deployment"
  codebuild_role_arn = module.cd_codebuild_role.iam_role_arn
  environment_variables = [
    {
      name  = "ECR_REGISTRY_URL"
      value = local.ecr_registry_url
    },
    {
      name  = "AWS_REGION"
      value = var.region
    },
    {
      name  = "EKS_CLUSTER_NAME"
      value = var.cluster_name
    }
  ]
  tags = var.default_tags
}

// Common artifacts deployment pipeline for CI/CD
module "common_deployment_pipeline" {
  source               = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Code-Pipeline?ref=UnitOfWork"
  pipeline_name        = "common-deployment"
  project              = var.project
  pipeline_role_arn    = module.codepipeline_role.iam_role_arn
  stages               = local.common_deployment_stages
  artifact_bucket_name = join("-", [var.project, var.cd_bucket_name, var.environment, var.region, "bucket"])
  tags                 = var.default_tags
}

module "cd_integration_s3_bucket" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/S3-Account?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  application = var.integration_bucket_name
  tags        = var.default_tags
}

module "integration_project_build" {
  source             = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Code-Build?ref=UnitOfWork"
  project            = var.project
  description        = "CD project to build common artifacts for Kubernetes deployment"
  build_name         = "integration-k8s-deployment"
  codebuild_role_arn = module.cd_codebuild_role.iam_role_arn
  environment_variables = [
    {
      name  = "ECR_REGISTRY_URL"
      value = local.ecr_registry_url
    },
    {
      name  = "AWS_REGION"
      value = var.region
    },
    {
      name  = "EKS_CLUSTER_NAME"
      value = var.cluster_name
    }
  ]
  codebuild_source = {
    type      = "CODEPIPELINE"
    buildspec = "buildspec_integration.yml"
  }
  tags = var.default_tags
}

// Integration artifacts deployment pipeline for CI/CD
module "integration_deployment_pipeline" {
  source               = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Code-Pipeline?ref=UnitOfWork"
  pipeline_name        = "integration-deployment"
  project              = var.project
  pipeline_role_arn    = module.codepipeline_role.iam_role_arn
  stages               = local.integration_deployment_stages
  artifact_bucket_name = join("-", [var.project, var.integration_bucket_name, var.environment, var.region, "bucket"])
  tags                 = var.default_tags
}
