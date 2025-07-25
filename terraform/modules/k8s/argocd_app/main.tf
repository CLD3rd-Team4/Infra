resource "kubernetes_manifest" "argocd_application_schedule" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = var.app_name
      namespace = "argocd"
    }
    spec = {
      destination = {
        namespace = var.destination_namespace
        server    = "https://kubernetes.default.svc"
      }
      source = {
        path           = var.source_path
        repoURL        = var.repo_url
        targetRevision = terraform.workspace == "prod" ? "main" : terraform.workspace
      }
      project = "default"
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }
}