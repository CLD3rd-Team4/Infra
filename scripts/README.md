# Kubernetes & Helm Setup Scripts

이 스크립트들은 기존 Terraform의 k8s_helm.tf에서 관리하던 모든 Kubernetes 및 Helm 리소스를 설치합니다.

## 사용법

### Windows
```cmd
cd scripts
setup-k8s-windows.bat
```

### Windows (Config Server Secrets와 함께)
```cmd
cd scripts
set GIT_USERNAME=your-username
set GIT_TOKEN=your-token
setup-k8s-windows.bat
```

### macOS/Linux
```bash
cd scripts
chmod +x setup-k8s-mac.sh
./setup-k8s-mac.sh
```

### macOS/Linux (Config Server Secrets와 함께)
```bash
cd scripts
chmod +x setup-k8s-mac.sh
GIT_USERNAME=your-username GIT_TOKEN=your-token ./setup-k8s-mac.sh
```

## 설치되는 컴포넌트

1. **AWS Load Balancer Controller** - ALB/NLB 관리
2. **External DNS** - Route53 DNS 자동 관리
3. **ArgoCD** - GitOps 배포 도구
4. **Metrics Server** - 리소스 메트릭 수집
5. **Kube Ops View** - 클러스터 시각화
6. **Cluster Autoscaler** - 노드 자동 스케일링
7. **Istio** - 서비스 메시
   - Istio Base
   - Istiod
   - Istio Ingress Gateway
   - Jaeger (분산 추적)
8. **Prometheus** - 모니터링 및 메트릭 수집
9. **Sealed Secrets Controller** - Secret 암호화 관리

## 네임스페이스

다음 네임스페이스가 생성됩니다:
- `external-dns`
- `argocd`
- `monitoring`
- `istio-system`
- `service-review` (Istio injection 활성화)
- `service-recommend` (Istio injection 활성화)
- `service-schedule` (Istio injection 활성화)
- `service-platform` (Istio injection 활성화)

## Config Server Secrets

Config Server가 사용하는 암호화된 Secret들은 **ArgoCD가 SealedSecret으로 관리**합니다.

### SealedSecret 값 생성

**macOS/Linux:**
```bash
cd scripts
chmod +x generate-sealed-secrets.sh
GIT_USERNAME=your-github-username GIT_TOKEN=your-github-token ./generate-sealed-secrets.sh
```

**Windows:**
Windows에서는 macOS/Linux 환경에서 값을 생성하거나, WSL을 사용하세요.

### 설정 방법

1. **SealedSecret 값 생성**: 위 스크립트 실행
2. **파일 수정**: `argocd/sealed-secrets.yaml`에서 REPLACE_WITH_* 부분을 생성된 값으로 교체
3. **커밋 & 푸시**: Git에 커밋하고 푸시
4. **자동 배포**: ArgoCD가 자동으로 SealedSecret을 배포

### 관리되는 Secret들:
- `config-server-encrypt-secret`: Config Server 암호화 키 (자동 생성)
- `config-server-git-secret`: GitHub 인증 정보 (환경변수에서)

### 파일 위치:
- **SealedSecret 정의**: `argocd/sealed-secrets.yaml`
- **Config Server 배포**: `argocd/platform/config.yaml`

## 설정 변수

스크립트 상단에서 다음 변수들을 수정할 수 있습니다:
- `CLUSTER_NAME`: EKS 클러스터 이름
- `REGION`: AWS 리전
- `SERVICE_DOMAIN`: 서비스 도메인
- `PROMETHEUS_RETENTION`: Prometheus 데이터 보존 기간
- `TRACING_SAMPLING_PERCENTAGE`: 분산 추적 샘플링 비율

## 반복 실행

스크립트는 `helm upgrade --install`과 `kubectl apply`를 사용하므로 **반복 실행해도 안전**합니다. 이미 설치된 컴포넌트는 업그레이드되거나 변경사항이 없으면 그대로 유지됩니다.

## ArgoCD 애플리케이션

스크립트 실행 시 다음 4개의 ArgoCD 애플리케이션이 자동으로 생성됩니다:
- `mapzip-dev-service-schedule`
- `mapzip-dev-service-recommend` 
- `mapzip-dev-service-review`
- `mapzip-dev-service-platform`

각 애플리케이션은 GitHub 리포지토리의 `argocd/` 디렉토리에서 매니페스트를 가져와 자동 동기화됩니다.

## 주의사항

1. 스크립트 실행 전에 다음이 설치되어 있어야 합니다:
   - kubectl
   - helm
   - aws cli (인증 설정 완료)
   - kubeseal (Config Server Secrets 생성 시)

2. EKS 클러스터가 이미 생성되어 있어야 합니다.

3. Terraform에서 생성한 IRSA 역할들이 필요합니다:
   - AWS Load Balancer Controller 역할
   - External DNS 역할
   - Cluster Autoscaler 역할

4. Config Server Secrets 생성 시 GitHub Personal Access Token이 필요합니다.