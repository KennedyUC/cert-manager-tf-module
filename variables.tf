variable "helm_create_namespace" {
    type        = bool
    default     = False
    description = "Specify the whether namespace is created by Helm"
}

variable "enable_atomic" {
    type        = bool
    default     = False
    description = "Specify the whether atomic is enabled in Helm"
}

variable "cert_chart_version" {
    type        = string
    default     = "v1.9.1"
    description = "Specify the version of Helm"
}

variable "cert_chart_repo" {
    type        = string
    default     = "https://charts.jetstack.io"
    description = "helm chart repo"
}

variable "cert_namespace" {
    type        = string
    default     = "cert-manager"
    description = "cert-manager namespace"
}

variable "credential_path" {}

variable "gcp_project" {}

variable "cluster_name" {}

variable "cluster_location" {}