// fetch the kubernetes manifests
data "kubectl_path_documents" "manifests" {
    pattern = "../manifest/*.yaml"
} 

// deploy the kubernetes resources to the cluster
resource "kubectl_manifest" "cert-manager" {
    count     = length(data.kubectl_path_documents.manifests.documents)
    yaml_body = element(data.kubectl_path_documents.manifests.documents, count.index)
}

// install cert manager using helm
resource "helm_release" "cert-manager" {
  depends_on       = [kubectl_manifest.cert-manager]
  name             = "cert-manager"
  namespace        = var.cert_namespace
  create_namespace = var.helm_create_namespace
  chart            = "cert-manager"
  repository       = var.cert_chart_repo
  version          = var.cert_chart_version
  values = [
    file("${var.cert-manager-chart-values}")]
  atomic           = var.enable_atomic
}