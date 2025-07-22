# Mapzip Terraform 프로젝트

## 1. 개요

이 프로젝트는 Mapzip 서비스의 인프라를 Terraform으로 관리하기 위한 코드베이스입니다. 모든 리소스는 모듈화하여 재사용성을 높이고, `terraform.workspace`를 사용해 개발(dev), 스테이징(stg), 운영(prod) 환경을 구분합니다.

## 2. 프로젝트 구조

```
.
├── README.md
├── argocd
│   └── ...
└── terraform
    ├── modules
    │   ├── aurora  # Aurora (PostgreSQL) 모듈
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   └── s3      # S3 버킷 모듈
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf
    ├── backend.tf
    ├── main.tf       # 루트 모듈 (모듈 호출)
    ├── outputs.tf
    ├── providers.tf
    └── variables.tf
```

- **`main.tf`**: 각 모듈을 호출하여 전체 인프라를 구성합니다.
- **`variables.tf`**: 전역적으로 사용되는 변수를 정의합니다. (VPC, Subnet ID 등)
- **`outputs.tf`**: 생성된 리소스의 주요 정보를 출력합니다.
- **`modules/`**: 각 리소스별 모듈이 위치합니다.
  - **`aurora/`**: Aurora PostgreSQL 클러스터 모듈
  - **`s3/`**: S3 버킷 모듈

## 3. 공통 규칙

### 네이밍 규칙

모든 리소스의 이름은 `mapzip-{환경명}-{리소스명}` 형식을 따릅니다. 환경명은 `terraform.workspace`를 통해 동적으로 결정됩니다.

```hcl
locals {
  common_prefix = "mapzip-${terraform.workspace}-"
  common_tags = {
    Environment = terraform.workspace
    Project     = "mapzip"
    ManagedBy   = "Terraform"
  }
}
```

### 태그 관리

모든 리소스에는 `local.common_tags`에 정의된 공통 태그가 필수로 포함되어야 합니다.

## 4. 사용법

### 환경 초기화

최초 실행 시 또는 새로운 환경(workspace)을 추가할 때 아래 명령어를 실행합니다.

```bash
terraform init
terraform workspace new dev
```

### 계획 및 적용

Terraform 코드를 변경한 후에는 항상 `plan`을 통해 변경 사항을 확인하고 `apply`로 적용합니다.

```bash
# dev 환경에 대한 변경 계획 확인
terraform plan -var-file="dev.tfvars"

# dev 환경에 변경 사항 적용
terraform apply -var-file="dev.tfvars"
```

**참고**: `dev.tfvars` 파일에는 VPC ID, Subnet ID 등 환경별 변수를 정의해야 합니다. 이 파일은 `.gitignore`에 추가하여 형상 관리에 포함되지 않도록 주의해야 합니다.

## 5. 모듈 상세 설명

### Aurora 모듈 (`modules/aurora`)

- **기능**: `aurora-postgresql` 엔진을 사용하는 DB 클러스터를 생성합니다.
- **주요 변수**:
  - `vpc_id`: DB가 위치할 VPC ID
  - `private_subnet_ids`: DB 클러스터가 사용할 Private Subnet ID 목록
  - `allowed_security_group_id`: DB 접근을 허용할 보안 그룹 ID
- **참고**: DB 이름, 계정, 비밀번호는 임시값을 사용하며, 추후 `SecretsManager`와 연동될 예정입니다.

### S3 모듈 (`modules/s3`)

- **기능**: 다용도 S3 버킷을 생성합니다.
- **주요 변수**:
  - `bucket_name`: 생성할 버킷의 기본 이름 (prefix가 추가됨)
  - `is_public`: 버킷의 Public 접근 허용 여부 (기본값: `false`)
- **참고**: 현재 모든 버킷은 비공개(private)로 설정되며, 버전 관리는 비활성화되어 있습니다.

## 6. TODO

- [ ] `SecretsManager`를 연동하여 DB 계정 정보 관리
- [ ] S3 버킷 Public 접근 정책 구체화
- [ ] EKS 클러스터 구성 및 `depends_on` 설정
