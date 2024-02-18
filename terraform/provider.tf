terraform {
  required_version = "~> 1.3.3"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.58.0"
    }
    helm = {
        source  = "hashicorp/helm"
        version = "~> 2.6"
    }
  }
}

provider "aws" {
   region = "us-east-1"
   assume_role {
    role_arn     = var.terraform_assume_role // optional
    session_name = "Terraform"
    external_id  = var.external_id // optional
  }
}

data aws_eks_cluster cluster {
  name  = aws_eks_cluster.cluster.id
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}
variable "cluster_name" {
  default = "demo"
}

variable "terraform_assume_role" {
  type = string
}

variable "external_id" {
  type = string
}