// connect to the kubernetes cluster
resource "null_resource" "connect_k8s" {
  provisioner "local-exec" {
    command = "sudo gcloud auth activate-service-account --key-file ../credentials/gcp-credentials.json"
  }
  provisioner "local-exec" {
    command = "sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin"
  }
  provisioner "local-exec" {
    command = "sudo gcloud config set project my-new-project-1-364319"
  }
  provisioner "local-exec" {
    command = "sudo gcloud config set container/cluster terraform-cluster"
  }
  provisioner "local-exec" {
    command = "sudo gcloud config set compute/zone us-central1-a"
  }
  provisioner "local-exec" {
    command = "sudo gcloud container clusters get-credentials terraform-cluster --zone us-central1-a --project my-new-project-1-364319"
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
  namespace        = "cert-manager"
  create_namespace = var.create_namespace
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  version          = "v1.9.1"
  values = [
    file("./helm-values/cert-manager-values.yaml")]
  atomic           = var.enable_atomic
}