@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Kubernetes and Helm Setup Script (Windows)
echo ========================================

REM Check if kubectl is available
kubectl version --client >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: kubectl is not installed or not in PATH
    exit /b 1
)

REM Check if helm is available
helm version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: helm is not installed or not in PATH
    exit /b 1
)

REM Get cluster name from terraform output or use default
set CLUSTER_NAME=mapzip-dev-eks
set REGION=ap-northeast-2
set SERVICE_DOMAIN=mapzip.shop
set PROMETHEUS_RETENTION=15d
set TRACING_SAMPLING_PERCENTAGE=100

REM 각자 프로필에 맞게 변경
set AWS_PROFILE=lt4

echo Updating kubeconfig...
aws eks update-kubeconfig --region %REGION% --name %CLUSTER_NAME%

REM AWS 계정 ID를 가져와서 환경 변수로 설정
for /f "delims=" %%i in ('aws sts get-caller-identity --query Account --output text') do set "AWS_ID=%%i"

REM 설정된 AWS_ID 출력 (확인용)
echo AWS_ID is: %AWS_ID%

echo Adding Helm repositories...
helm repo add aws-eks https://aws.github.io/eks-charts
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo add geek-cookbook https://geek-cookbook.github.io/charts/
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update

echo Creating namespaces...
kubectl create namespace external-dns --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace istio-system --dry-run=client -o yaml | kubectl apply -f -

REM Create service namespaces with Istio injection
kubectl create namespace service-review --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace service-recommend --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace service-schedule --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace service-platform --dry-run=client -o yaml | kubectl apply -f -

kubectl label namespace service-review istio-injection=enabled --overwrite
kubectl label namespace service-recommend istio-injection=enabled --overwrite
kubectl label namespace service-schedule istio-injection=enabled --overwrite
kubectl label namespace service-platform istio-injection=enabled --overwrite
kubectl label namespace monitoring istio-injection=enabled --overwrite
kubectl label namespace istio-system topology.istio.io/network=network1 --overwrite

REM 서브넷 ID 조회
for /f "delims=" %%i in ('aws eks describe-cluster --name %CLUSTER_NAME% --query "cluster.resourcesVpcConfig.subnetIds[0]" --output text') do (
    set SUBNET_ID=%%i
)

REM VPC ID 조회
for /f "delims=" %%i in ('aws ec2 describe-subnets --subnet-ids %SUBNET_ID% --query "Subnets[0].VpcId" --output text') do (
    set VPC_ID=%%i
)

echo VPC ID is: %VPC_ID%

echo Installing AWS Load Balancer Controller...
helm upgrade --install aws-load-balancer-controller aws-eks/aws-load-balancer-controller ^
  --namespace kube-system ^
  --set clusterName=%CLUSTER_NAME% ^
  --set region=%REGION% ^
  --set vpcId=%VPC_ID% ^
  --set serviceAccount.name=aws-load-balancer-controller ^
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::%AWS_ID%:role/mapzip-dev-alb-irsa-role ^
  --set serviceAccount.create=true ^
  --set serviceAccount.name=aws-load-balancer-controller ^
  --version 1.7.1 ^
  --wait

echo Installing External DNS...
helm upgrade --install external-dns external-dns/external-dns ^
  --namespace external-dns ^
  --set provider.name=aws ^
  --set serviceAccount.create=true ^
  --set serviceAccount.name=external-dns ^
  --set rbac.create=true ^
  --set txtOwnerId=%CLUSTER_NAME% ^
  --set env[0].name=AWS_DEFAULT_REGION ^
  --set env[0].value=%REGION% ^
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::%AWS_ID%:role/mapzip-dev-external-dns-irsa-role ^
  --set args[0]="--annotation-filter=external-dns.alpha.kubernetes.io/hostname" ^
  --set domainFilters[0]=%SERVICE_DOMAIN% ^
  --version 1.18.0 ^
  --wait

echo Installing ArgoCD...
helm upgrade --install argocd argo/argo-cd ^
  --namespace argocd ^
  --set server.service.type=LoadBalancer ^
  --set server.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"=internal ^
  --set server.service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"=argocd.%SERVICE_DOMAIN% ^
  --version 8.2.0 ^
  --timeout 600s ^
  --wait

echo Installing Metrics Server...
helm upgrade --install metric-server metrics-server/metrics-server ^
  --namespace kube-system ^
  --set args[0]="--kubelet-insecure-tls" ^
  --version 3.13.0 ^
  --wait

echo Installing Kube Ops View...
helm upgrade --install kube-ops-view geek-cookbook/kube-ops-view ^
  --namespace kube-system ^
  --set service.main.type=LoadBalancer ^
  --set service.main.ports.http.port=8080 ^
  --set service.main.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"=internal ^
  --set service.main.annotations."external-dns\.alpha\.kubernetes\.io/hostname"=kubeopsview.%SERVICE_DOMAIN% ^
  --version 1.2.2 ^
  --timeout 600s ^
  --wait

echo Installing Cluster Autoscaler...
helm upgrade --install cluster-autoscaler autoscaler/cluster-autoscaler ^
  --namespace kube-system ^
  --set autoDiscovery.clusterName=%CLUSTER_NAME% ^
  --set awsRegion=%REGION% ^
  --set rbac.create=true ^
  --set rbac.serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::%AWS_ID%:role/mapzip-dev--cluster-autoscaler-irsa ^
  --set rbac.serviceAccount.name=cluster-autoscaler ^
  --version 9.48.0 ^
  --wait

echo Installing Istio Base...
helm upgrade --install istio-base istio/base ^
  --namespace istio-system ^
  --version 1.26.2 ^
  --wait

echo Creating Jaeger deployment and services...
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.26/samples/addons/jaeger.yaml


echo Installing Istiod...
helm upgrade --install istiod istio/istiod ^
  --namespace istio-system ^
  --set global.meshID=multicluster-mesh ^
  --set global.multiCluster.clusterName=cluster1 ^
  --set global.network=network1 ^
  --set meshConfig.enableTracing=true ^
  --set meshConfig.extensionProviders[0].name=jaeger ^
  --set meshConfig.extensionProviders[0].opentelemetry.service=jaeger-collector.istio-system.svc.cluster.local ^
  --set meshConfig.extensionProviders[0].opentelemetry.port=4317 ^
  --version 1.26.2 ^
  --wait

echo Installing Istio Ingress Gateway...
helm upgrade --install istio-ingressgateway istio/gateway ^
  --namespace istio-system ^
  --set service.type=NodePort ^
  --version 1.26.2 ^
  --wait

echo Installing Prometheus...
helm upgrade --install prometheus prometheus-community/prometheus ^
  --namespace monitoring ^
  --set global.scrape_interval=15s ^
  --set server.retention=%PROMETHEUS_RETENTION% ^
  --set server.service.type=LoadBalancer ^
  --set server.service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"=prometheus.%SERVICE_DOMAIN% ^
  --set server.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"=internal ^
  --set server.persistentVolume.storageClass=gp2 ^
  --set alertmanager.persistentVolume.storageClass=gp2 ^
  --values ./values/prometheus-values.yaml ^
  --version 27.28.1 ^
  --wait

echo Creating Istio Telemetry configuration...
kubectl apply -f values/istio-telemetry.yaml

echo Creating Cross Network Gateway...
kubectl apply -f values/cross-network-gateway.yaml

echo Creating ArgoCD Applications...
kubectl apply -f values/argocd-applications.yaml

echo Installing Sealed Secrets Controller...
helm upgrade --install sealed-secrets sealed-secrets/sealed-secrets --namespace kube-system --version 2.15.4 --wait

echo Waiting for Sealed Secrets Controller to be ready...
kubectl wait --for=condition=available --timeout=300s deployment/sealed-secrets-controller -n kube-system

echo Note: Config Server Secrets are now managed by ArgoCD via SealedSecrets
echo To generate SealedSecret values, use generate-sealed-secrets.sh on macOS/Linux

echo ========================================
echo Setup completed successfully!
echo ========================================
echo.
echo All components installed:
echo - AWS Load Balancer Controller
echo - External DNS
echo - ArgoCD with 4 applications
echo - Metrics Server
echo - Kube Ops View
echo - Cluster Autoscaler
echo - Istio (Base, Istiod, Ingress Gateway)
echo - Jaeger (Distributed Tracing)
echo - Prometheus
echo - Sealed Secrets Controller
echo.
echo Verify all services: kubectl get pods --all-namespaces
echo ArgoCD UI: kubectl get svc -n argocd