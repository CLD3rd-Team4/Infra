# 인프라 주요 변경 이력 (Aurora DB, S3, ElastiCache, DynamoDB, MSK 중심)

최근 인프라에 Aurora 데이터베이스, S3 스토리지, ElastiCache, DynamoDB, MSK 모듈이 추가되고, 관련하여 `main.tf`의 병합 충돌을 해결하는 과정이 있었습니다. 이 문서는 해당 변경 사항에 대한 상세 설명과 팀원들이 유의해야 할 점을 정리합니다.

---

### 1. Aurora DB 모듈 (`./modules/aurora`)

**1-1. 모듈의 역할**
- AWS의 고가용성 관계형 데이터베이스 서비스인 Aurora (PostgreSQL 버전) 클러스터를 생성하고 관리합니다.
- 물리적인 DB 서버(클러스터)와 인스턴스, 관련 네트워크 설정(보안 그룹, 서브넷 그룹)을 책임집니다.

**1-2. 루트 모듈(`main.tf`)에서의 사용법**
- `module "aurora_db"` 블록을 통해 이 모듈을 호출합니다.
- 필요한 값들(VPC ID, Private Subnet ID 목록, DB 인스턴스 사양 등)을 변수로 전달받아 클러스터를 구성합니다.

**1-3. (중요) 데이터베이스 생성 방식 상세 설명**
- **물리적 클러스터 vs 논리적 데이터베이스:**
  - `aurora` 모듈은 데이터베이스 소프트웨어가 설치된 서버 그룹, 즉 **물리적인 DB 클러스터**만 생성합니다.
  - 우리가 실제로 사용할 `mapzip_user`, `mapzip_post` 같은 **논리적인 데이터베이스**는 이 모듈이 직접 만들지 않습니다.

- **논리적 데이터베이스는 누가 만드는가?**
  - 루트 `main.tf`에 있는 `resource "postgresql_database" "dbs"` 코드가 이 역할을 수행합니다.
  - 이 코드는 생성된 Aurora DB 클러스터에 접속해서, `CREATE DATABASE ...` 명령을 실행해주는 것과 같습니다.

- **어떤 이름으로 만들어지는가?**
  - `variables.tf`에 정의된 `variable "databases"`라는 맵(map) 변수를 사용합니다.
  - 예를 들어, Terraform Cloud나 `.tfvars` 파일에 아래와 같이 변수를 설정하면:
    ```tf
    databases = {
      "user" = { password = "..." },
      "post" = { password = "..." }
    }
    ```
  - `for_each` 루프가 `user`와 `post`라는 키(key)를 각각 순회하면서 `mapzip_user`, `mapzip_post` 라는 이름의 데이터베이스 2개를 생성해줍니다.

---

### 2. S3 모듈 (`./modules/s3`)

**2-1. 모듈의 역할**
- AWS의 객체 스토리지 서비스인 S3 버킷을 생성하고 관리합니다.
- 버킷 이름, 공개 여부, 정적 웹사이트 호스팅 기능 등을 설정할 수 있도록 만들어졌습니다.

**2-2. 루트 모듈(`main.tf`)에서의 사용법**
- 현재 두 가지 용도로 S3 모듈을 호출하고 있습니다.
  1.  `module "s3_image_bucket"`: 이미지 파일을 저장하기 위한 **비공개(private)** 버킷을 생성합니다.
  2.  `module "s3_website_bucket"`: 프론트엔드 빌드 결과물(HTML, JS, CSS)을 저장하고 외부에 서비스하기 위한 **공개(public)** 버킷을 생성합니다.

**2-3. CloudFront 연동**
- `cloudfront` 모듈과 `cloudfront_image` 모듈은 각각의 S3 버킷을 원본(Origin)으로 바라봅니다.
- `main.tf`에서 S3 모듈의 출력 값인 `bucket_domain_name`을 CloudFront 모듈의 입력 변수로 전달하여 둘을 연결합니다.
  - `s3_website_bucket` -> `cloudfront`
  - `s3_image_bucket` -> `cloudfront_image`

---

### 3. ElastiCache (Valkey) 모듈 (`./modules/elasticache`)

**3-1. 모듈의 역할**
- AWS의 인메모리 데이터 스토어 서비스인 ElastiCache (Valkey 엔진) 클러스터를 생성하고 관리합니다.
- 빠른 데이터 접근이 필요한 서비스(예: 인증 토큰 저장, 캐싱)를 위해 사용됩니다.
- 클러스터 노드, 파라미터 그룹, 네트워크 설정(보안 그룹, 서브넷 그룹)을 관리합니다.

**3-2. 루트 모듈(`main.tf`)에서의 사용법**
- `module "elasticache_auth"`, `module "elasticache_recommend"` 와 같이 서비스별로 모듈을 호출합니다.
- `name_prefix`, `cluster_name`, `node_type` 등 필요한 값을 변수로 전달하여 클러스터를 구성합니다.

**3-3. (중요) Valkey 엔진 사용**
- ElastiCache 모듈은 **Valkey** 엔진을 사용하도록 설정되어 있습니다.
- AWS 정책상 Valkey 엔진은 `aws_elasticache_cluster`가 아닌 `aws_elasticache_replication_group` 리소스를 통해 생성해야 합니다. 모듈 내부 코드가 이에 맞게 작성되어 있습니다.

---

### 4. DynamoDB 모듈 (`./modules/dynamodb`)

**4-1. 모듈의 역할**
- AWS의 NoSQL 데이터베이스 서비스인 DynamoDB 테이블을 생성하고 관리합니다.
- 스키마가 유연하고 확장성이 중요한 데이터(예: 리뷰, 사용자 프로필)를 저장하는 데 사용됩니다.
- 테이블 이름, 파티션 키, 정렬 키, 속성 등을 정의합니다.

**4-2. 루트 모듈(`main.tf`)에서의 사용법**
- `module "dynamodb"` 블록을 통해 모듈을 호출합니다.
- `table_name`, `attributes`, `hash_key` 등의 변수를 통해 테이블 스키마를 정의합니다.

---

### 5. MSK (Managed Streaming for Kafka) 모듈 (`./modules/msk`)

**5-1. 모듈의 역할**
- AWS의 완전관리형 Apache Kafka 서비스인 MSK 클러스터를 생성하고 관리합니다.
- 서비스 간 비동기 메시지 통신, 이벤트 스트리밍, 실시간 데이터 파이프라인 구축을 위해 사용됩니다.
- 클러스터 이름, 브로커 노드 수, Kafka 버전, 네트워크 설정 등을 관리합니다.

**5-2. 루트 모듈(`main.tf`)에서의 사용법**
- `module "msk"` 블록을 통해 모듈을 호출합니다.
- `cluster_name`, `kafka_version`, `number_of_broker_nodes` 등 클러스터 구성을 위한 변수를 전달합니다.
- MSK는 Private Subnet에 배포되며, EKS 클러스터나 다른 서비스들이 접근할 수 있도록 보안 그룹이 설정되어 있습니다.

---

### 6. 팀원 유의사항 (필독)

**6-1. `main.tf` 병합 충돌 해결**
- 최근 `main.tf` 파일에 `eks`, `iam`, `route53`, `s3`, `aurora` 등 여러 모듈이 동시에 추가되면서 병합 충돌이 있었습니다.
- 현재는 양쪽 브랜치의 변경 사항을 모두 반영하여 코드를 통합했으며, 모든 모듈이 정상적으로 포함되어 있습니다.
- 특히 `eks` 모듈에 `vpc_id`와 `public_access_cidrs` 같은 필수 변수가 정확히 전달되도록 수정되었으니 참고 바랍니다.

**6-2. 모듈화 및 일관성**
- 모든 신규 서비스(ElastiCache, DynamoDB, MSK)는 재사용성과 관리 용이성을 위해 Terraform 모듈로 구성되었습니다.
- 각 모듈은 `variables.tf`를 통해 필요한 설정을 주입받으며, `outputs.tf`를 통해 생성된 리소스의 정보(예: 클러스터 엔드포인트, 테이블 ARN)를 외부에 제공합니다.

**6-3. 명명 규칙 (Naming Convention)**
- 모든 리소스는 `name_prefix` 변수(예: `mapzip-dev-`)를 사용하여 일관된 명명 규칙을 따릅니다. 이를 통해 리소스의 용도와 환경(dev, prod)을 쉽게 식별할 수 있습니다.

**6-4. 네트워크 및 보안**
- 각 모듈은 `main.tf`에서 전달받은 VPC ID와 서브넷 ID를 사용하여 기존 네트워크 환경 내에 배포됩니다.
- 서비스 간 통신은 보안 그룹(Security Group)을 통해 제어됩니다. 각 모듈은 필요한 보안 그룹 ID를 변수로 전달받거나 직접 생성하여 사용합니다.
