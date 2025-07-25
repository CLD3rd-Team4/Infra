resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.1"

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "region"
      value = var.region
    },
    {
      name  = "vpcId"
      value = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.eks.aws_load_balancer_controller_role_arn
    }
  ]

  depends_on = [module.eks]
}



resource "helm_release" "external-dns" {
  name       = "external-dns"
  namespace  = "external-dns"
  create_namespace = true
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.18.0"

  set = [
    {
      name  = "provider.name"
      value = "aws"
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "external-dns"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.eks.external_dns_role_arn
    },
    {
      name = "rbac.create"
      value = "true"
    },
    {
      name = "txtOwnerId"
      value = var.cluster_name
    },
    {
      name  = "env[0].name"
      value = "AWS_DEFAULT_REGION"
    },
    {
      name  = "env[0].value"
      value = var.region
    },
    {
      name  = "args[0]"
      value = "--annotation-filter=external-dns.alpha.kubernetes.io/hostname"
    }
  ]

  set_list = [
    {
      name = "domainFilters"
      value = [var.service_domain]
    }
  ]

  depends_on = [module.eks, helm_release.aws_load_balancer_controller]
  
}



resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  create_namespace = true
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.2.0"

  set = [
    {
      name  = "server.service.type"
      value = "LoadBalancer"
    },
    {
      name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
      value = "internal"
    },
    {
      name  = "server.service.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
      value = "argocd.${var.service_domain}"
    }

  ]

  timeout = "600"

  depends_on = [module.eks, helm_release.aws_load_balancer_controller, helm_release.external-dns]  
}

module "argocd_application_schedule" {
  count = var.is_crd_dependent_phase ? 1 : 0
  source              = "./modules/k8s/argocd_app"
  app_name            = "${local.common_prefix}service-schedule"
  destination_namespace = "service-schedule"
  source_path         = "argocd/service-schedule"
  repo_url            = "https://github.com/CLD3rd-Team4/Infra"

  depends_on = [module.eks, helm_release.argocd]
}

module "argocd_application_recommend" {
  count = var.is_crd_dependent_phase ? 1 : 0
  source              = "./modules/k8s/argocd_app"
  app_name            = "${local.common_prefix}service-recommend"
  destination_namespace = "service-recommend"
  source_path         = "argocd/service-recommend"
  repo_url            = "https://github.com/CLD3rd-Team4/Infra"

  depends_on = [module.eks, helm_release.argocd]
}

module "argocd_application_review" {
  count = var.is_crd_dependent_phase ? 1 : 0
  source              = "./modules/k8s/argocd_app"
  app_name            = "${local.common_prefix}service-review"
  destination_namespace = "service-review"
  source_path         = "argocd/service-review"
  repo_url            = "https://github.com/CLD3rd-Team4/Infra"

  depends_on = [module.eks, helm_release.argocd]
}

module "argocd_application_platform" {
  count = var.is_crd_dependent_phase ? 1 : 0
  source              = "./modules/k8s/argocd_app"
  app_name            = "${local.common_prefix}service-platform"
  destination_namespace = "service-platform"
  source_path         = "argocd/service-platform"
  repo_url            = "https://github.com/CLD3rd-Team4/Infra"

  depends_on = [module.eks, helm_release.argocd]
}



resource "helm_release" "metric-server" {
  name       = "metric-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.13.0"

  set = [
    {
      name  = "args[0]"
      value = "--kubelet-insecure-tls"
    }
  ]

  depends_on = [module.eks]
}



resource "helm_release" "kube_ops_view" {
  name       = "kube-ops-view"
  namespace  = "kube-system"
  repository = "https://geek-cookbook.github.io/charts/"
  chart      = "kube-ops-view"
  version    = "1.2.2"

  set = [
    {
      name  = "service.main.type"
      value = "LoadBalancer"
    },
    {
        name  = "service.main.ports.http.port"
        value = "8080"
      },
    {
      name  = "service.main.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
      value = "internal"
    },
    {
      name  = "service.main.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
      value = "kubeopsview.${var.service_domain}"
    }
  ]
  timeout    = 600
  depends_on = [ module.eks, helm_release.aws_load_balancer_controller, helm_release.external-dns ]
}


resource "helm_release" "cluster-autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.48.0"

  set = [
    {
      name  = "autoDiscovery.clusterName"
      value = var.cluster_name
    },
    {
      name  = "awsRegion"
      value = var.region
    },
    {
      name  = "rbac.create"
      value = "true"
    },
    {
      name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.eks.cluster_autoscaler_irsa_role_arn
    },
    {
      name  = "rbac.serviceAccount.name"
      value = "cluster-autoscaler"
    }
  ]

  depends_on = [module.eks]
}



resource "kubernetes_namespace" "service-review" {
  metadata {
    name = "service-review"
    labels = {
      "istio-injection" = "enabled"
    }
  }
  depends_on = [module.eks]
}

resource "kubernetes_namespace" "service-recommend" {
  metadata {
    name = "service-recommend"
    labels = {
      "istio-injection" = "enabled"
    }
  }
  depends_on = [module.eks]
}
resource "kubernetes_namespace" "service-schedule" {
  metadata {
    name = "service-schedule"
    labels = {
      "istio-injection" = "enabled"
    }
  }
  depends_on = [module.eks]
}
resource "kubernetes_namespace" "service-platform" {
  metadata {
    name = "service-platform"
    labels = {
      "istio-injection" = "enabled"
    }
  }
  depends_on = [module.eks]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      "istio-injection" = "enabled"
    }
  }
  depends_on = [module.eks]
}


# Istio 설치 및 설정
resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"

    labels = {
      "topology.istio.io/network" = "network1"
    }
  }
  depends_on = [module.eks]
}


resource "helm_release" "istio_base" {
  name       = "istio-base"
  namespace  = "istio-system"
  create_namespace = true
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = "1.26.2"


  depends_on = [module.eks]
}

# Istio - Jaeger 설치
resource "kubernetes_deployment" "jaeger" {
  metadata {
    name      = "jaeger"
    namespace = "istio-system"
    labels = {
      app = "jaeger"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "jaeger"
      }
    }

    template {
      metadata {
        labels = {
          app                          = "jaeger"
          "sidecar.istio.io/inject"    = "false"
        }
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "14269"
        }
      }

      spec {
        container {
          name  = "jaeger"
          image = "docker.io/jaegertracing/all-in-one:1.67.0"

          env {
            name  = "BADGER_EPHEMERAL"
            value = "false"
          }
          env {
            name  = "SPAN_STORAGE_TYPE"
            value = "badger"
          }
          env {
            name  = "BADGER_DIRECTORY_VALUE"
            value = "/badger/data"
          }
          env {
            name  = "BADGER_DIRECTORY_KEY"
            value = "/badger/key"
          }
          env {
            name  = "COLLECTOR_ZIPKIN_HOST_PORT"
            value = ":9411"
          }
          env {
            name  = "MEMORY_MAX_TRACES"
            value = "50000"
          }
          env {
            name  = "QUERY_BASE_PATH"
            value = "/jaeger"
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 14269
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 14269
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/badger"
          }

          resources {
            requests = {
              cpu = "10m"
            }
          }
        }

        volume {
          name = "data"
          empty_dir {}
        }
      }
    }
  }
  depends_on = [module.eks, helm_release.istio_base]
}

# Istio - Jaeger - tracing 서비스 (UI 및 GRPC)
resource "kubernetes_service" "jaeger_tracing" {
  metadata {
    name      = "tracing"
    namespace = "istio-system"
    labels = {
      app = "jaeger"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "jaeger"
    }

    port {
      name        = "http-query"
      port        = 80
      target_port = 16686
    }

    port {
      name        = "grpc-query"
      port        = 16685
      target_port = 16685
    }
  }

  depends_on = [module.eks, kubernetes_deployment.jaeger]
}

# Istio - Jaeger - zipkin 서비스 (호환용)
resource "kubernetes_service" "zipkin" {
  metadata {
    name      = "zipkin"
    namespace = "istio-system"
    labels = {
      name = "zipkin"
    }
  }

  spec {
    selector = {
      app = "jaeger"
    }

    port {
      name        = "http-query"
      port        = 9411
      target_port = 9411
    }
  }

  depends_on = [module.eks, kubernetes_deployment.jaeger]
}

# Istio - Jaeger - jaeger-collector 서비스
resource "kubernetes_service" "jaeger_collector" {
  metadata {
    name      = "jaeger-collector"
    namespace = "istio-system"
    labels = {
      app = "jaeger"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "jaeger"
    }

    port {
      name        = "jaeger-collector-http"
      port        = 14268
      target_port = 14268
    }

    port {
      name        = "jaeger-collector-grpc"
      port        = 14250
      target_port = 14250
    }

    port {
      name        = "http-zipkin"
      port        = 9411
      target_port = 9411
    }

    port {
      name        = "grpc-otel"
      port        = 4317
      target_port = 4317
    }

    port {
      name        = "http-otel"
      port        = 4318
      target_port = 4318
    }
  }

  depends_on = [module.eks, kubernetes_deployment.jaeger]
}


resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = "istio-system"
  create_namespace = true
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.26.2"

  set = [
    {
      name  = "global.meshID" # 멀티클러스터 구성 시 mesh ID는 동일하게 설정
      value = "multicluster-mesh"
    },
    {
      name  = "global.multiCluster.clusterName" # 멀티클러스터 구성 시 각 클러스터 고유 ID
      value = "cluster1"
    },
    {
      name  = "global.network" 
      value = "network1" # 로컬은 network2
    },
    {
      name  = "meshConfig.enableTracing"
      value = "true"
    },
    {
      name  = "meshConfig.extensionProviders[0].name"
      value = "jaeger"
    },
    {
      name  = "meshConfig.extensionProviders[0].opentelemetry.service"
      value = "jaeger-collector.istio-system.svc.cluster.local"
    },
    {
      name  = "meshConfig.extensionProviders[0].opentelemetry.port"
      value = "4317"
    }
  ]

  depends_on = [module.eks, helm_release.istio_base]
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingressgateway"
  namespace  = "istio-system"
  create_namespace = true
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = "1.26.2"

  set = [
    {
      name  = "service.type"
      value = "NodePort"
    }
  ]

  depends_on = [module.eks, helm_release.istiod]
}

resource "kubernetes_ingress_v1" "istio_alb_ingress" {
  metadata {
    name      = "istio-alb-ingress"
    namespace = "istio-ingress"

    annotations = {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/healthz/ready"
      "alb.ingress.kubernetes.io/healthcheck-port"     = "traffic-port"
      "alb.ingress.kubernetes.io/certificate-arn"      = module.acm_backend.certificate_arn
      "alb.ingress.kubernetes.io/listen-ports"         = jsonencode([
        { "HTTP" = 80 },
        { "HTTPS" = 443 }
      ])
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/actions.ssl-redirect" = jsonencode({
        Type           = "redirect"
        RedirectConfig = {
          Protocol   = "HTTPS"
          Port       = "443"
          StatusCode = "HTTP_301"
        }
      })
      "external-dns.alpha.kubernetes.io/hostname"       = "api.${var.service_domain}"
      "alb.ingress.kubernetes.io/tags"  = "Environment=${terraform.workspace},Provisioner=Kubernetes"
    }

    labels = {
      app     = "Istio"
      ingress = "Istio"
    }
  }

  spec {
    rule {
      http {
        path {
          path     = "/*"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "ssl-redirect"
              port {
                name = "use-annotation"
              }
            }
          }
        }

        path {
          path     = "/healthz/ready"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "istio-ingressgateway"
              port {
                number = 15021
              }
            }
          }
        }

        path {
          path     = "/*"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "istio-ingressgateway"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [module.eks, helm_release.istio_ingress, helm_release.aws_load_balancer_controller, helm_release.external-dns]
}

# 멀티클러스터간 사이드카 mTLS용 게이트웨이
resource "kubernetes_manifest" "istio_crossnetwork_gateway" {
  count = var.is_crd_dependent_phase ? 1 : 0
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "Gateway"
    metadata = {
      name      = "cross-network-gateway"
      namespace = "istio-system"
    }
    spec = {
      selector = {
        app = "istio-crossnetworkgateway"
      }
      servers = [
        {
          port = {
            number   = 15443
            name     = "tls"
            protocol = "TLS"
          }
          tls = {
            mode = "AUTO_PASSTHROUGH"
          }
          hosts = ["*.local"]
        }
      ]
    }
  }

  depends_on = [module.eks, helm_release.istiod]
}

# 멀티클러스터 설정된 후에 해야함
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "monitoring"
  create_namespace = true
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "27.28.1"

  set = [
    {
      name  = "global.scrape_interval"
      value = "15s"
    },
    {
      name  = "server.retention"
      value = var.prometheus_retention
    },
    {
      name  = "server.service.type"
      value = "LoadBalancer"
    },
    {
      name  = "server.service.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
      value = "prometheus.${var.service_domain}"
    },
    {
      name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
      value = "internal"
    },
    {
      name = "server.persistentVolume.storageClass"
      value = "gp2"
    }
  ]

  values = [
    file("values/prometheus-values.yaml")
  ]

  depends_on = [module.eks, helm_release.external-dns, helm_release.istiod, helm_release.aws_load_balancer_controller]
  
}



resource "kubernetes_manifest" "istio_telemetry" {
  count = var.is_crd_dependent_phase ? 1 : 0
  manifest = {
    apiVersion = "telemetry.istio.io/v1"
    kind       = "Telemetry"
    metadata = {
      name      = "mesh-default"
      namespace = "istio-system"
    }
    spec = {
      tracing = [
        {
          # 100 = 모든 요청을 추적, 50 = 절반만 추적, 1 = 1%만 추적(100번 요청 중 1개만 기록)
          randomSamplingPercentage = var.tracing_sampling_percentage 
          providers = [
            {
              name = "jaeger"
            }
          ]
        }
      ]
    }
  }

  depends_on = [module.eks, helm_release.istiod]
}


# Fluent Bit 설치는 멀티클러스터 연결 후에 진행
