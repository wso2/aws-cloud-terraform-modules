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

module "codebuild_iam_policy" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Policy?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "codebuild"
  policy      = file(var.codebuild_iam_policy_path)
}

module "codebuild_role" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Role?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "codebuild"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
  policy_arns = [module.codebuild_iam_policy.iam_policy_arn]
}

module "codepipeline_iam_policy" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Policy?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "s3_management"
  policy      = file(var.codepipeline_iam_policy_path)
}

module "codepipeline_role" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Role?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "codepipeline"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
  policy_arns = [module.codepipeline_iam_policy.iam_policy_arn]
}

module "cd_codebuild_iam_policy" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Policy?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "cd-codebuild"
  policy      = file(var.cd_codebuild_iam_policy_path)
}

module "cd_codebuild_role" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Role?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "cd-codebuild"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Effect = "Allow"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = var.admin_role
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  policy_arns = [module.cd_codebuild_iam_policy.iam_policy_arn]
}

module "eks_access_entry" {
  source           = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/EKS-Access-Entry?ref=UnitOfWork"
  eks_cluster_name = var.cluster_name
  principal_arn    = module.cd_codebuild_role.iam_role_arn
  type             = "STANDARD"
}

module "eks_access_policy" {
  source           = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/EKS-Access-Policy?ref=UnitOfWork"
  eks_cluster_name = var.cluster_name
  principal_arn    = module.cd_codebuild_role.iam_role_arn
  policy_arn       = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  type             = "cluster"
}
