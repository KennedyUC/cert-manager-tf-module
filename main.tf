// connect to the kubernetes cluster
resource "null_resource" "connect_k8s" {
  provisioner "local-exec" {
    command = "sudo gcloud auth activate-service-account --key-file ${var.credential_path}"
  }
  provisioner "local-exec" {
    command = "sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin"
  }
  provisioner "local-exec" {
    command = "sudo gcloud config set project ${var.gcp_project}"
  }
  provisioner "local-exec" {
    command = "sudo gcloud config set container/cluster ${var.cluster_name}"
  }
  provisioner "local-exec" {
    command = "sudo gcloud config set compute/zone ${var.cluster_location}"
  }
  provisioner "local-exec" {
    command = "sudo gcloud container clusters get-credentials ${var.cluster_name} --zone ${cluster_location} --project ${var.gcp_project}"
  }
  provisioner "local-exec" {
    command = "sudo sleep 1m"
  }
}

// fetch the kubernetes manifests
data "kubectl_path_documents" "manifests" {
    pattern = "../manifest/*.yaml"
} 

// deploy the kubernetes resources to the cluster
resource "kubectl_manifest" "cert_manager" {
    count     = length(data.kubectl_path_documents.manifests.documents)
    yaml_body = element(data.kubectl_path_documents.manifests.documents, count.index)
}

// install cert manager using helm
resource "helm_release" "cert_manager" {
  depends_on       = [kubectl_manifest.cert_manager]
  name             = "cert-manager"
  namespace        = var.cert_namespace
  create_namespace = var.helm_create_namespace
  chart            = "cert-manager"
  repository       = var.cert_chart_repo
  version          = var.cert_chart_version
  values = [
    file("./helm-values/cert-manager-values.yaml")]
  atomic           = var.enable_atomic
}