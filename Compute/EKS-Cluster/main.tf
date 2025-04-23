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

module "eks_cluster_role" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/IAM-Role?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = "eks-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy-attach" {
  role       = module.eks_cluster_role.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

module "eks_cluster" {
  source      = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/EKS-Cluster?ref=UnitOfWork"
  project     = var.project
  environment = var.environment
  region      = var.region
  tags        = var.default_tags
  application = var.application

  kubernetes_version = var.k8s_version
  service_ipv4_cidr  = var.eks_service_ipv4_cidr
  cluster_subnet_ids = var.cluster_subnet_ids

  authentication_mode  = var.authentication_mode
  cluster_iam_role_arn = module.eks_cluster_role.iam_role_arn

  endpoint_public_access = var.eks_endpoint_public_access
  public_access_cidrs    = var.eks_public_access_cidrs
}

data "tls_certificate" "cert" {
  url = module.eks_cluster.eks_cluster_issuer
}

module "eks_oidc_provider" {
  count           = var.create_oidc_identity_provider ? 1 : 0
  source          = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/OpenID-Connect-Provider?ref=UnitOfWork"
  thumbprint_list = [data.tls_certificate.cert.certificates[0].sha1_fingerprint]
  tags            = var.default_tags
  url             = module.eks_cluster.eks_cluster_issuer
}

module "eks_security_group_ingress_rules" {
  source            = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Security-Group-Ingress-Rule?ref=UnitOfWork"
  security_group_id = module.eks_cluster.eks_security_group_id
  ingress-rules     = var.eks_security_group_ingress_rules
}

module "eks_security_group_egress_rules" {
  source            = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Security-Group-Egress-Rule?ref=UnitOfWork"
  security_group_id = module.eks_cluster.eks_security_group_id
  egress-rules      = var.eks_security_group_egress_rules
}

module "eks_access_entry" {
  source           = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/EKS-Access-Entry?ref=UnitOfWork"
  count            = length(var.access_entry)
  eks_cluster_name = module.eks_cluster.eks_cluster_name
  principal_arn    = var.access_entry[count.index].principal_arn
}

module "eks_access_policy" {
  source           = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/EKS-Access-Policy?ref=UnitOfWork"
  count            = length(var.access_entry)
  eks_cluster_name = module.eks_cluster.eks_cluster_name
  principal_arn    = var.access_entry[count.index].principal_arn
  policy_arn       = var.access_entry[count.index].policy_arn
  type             = var.access_entry[count.index].type
}
