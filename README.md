# 인프라 주요 변경 이력 (Aurora DB & S3 중심)

최근 인프라에 Aurora 데이터베이스와 S3 스토리지 모듈이 추가되고, 관련하여 `main.tf`의 병합 충돌을 해결하는 과정이 있었습니다. 이 문서는 해당 변경 사항에 대한 상세 설명과 팀원들이 유의해야 할 점을 정리합니다.

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

### 3. 팀원 유의사항 (필독)

**3-1. `main.tf` 병합 충돌 해결**
- 최근 `main.tf` 파일에 `eks`, `iam`, `route53`, `s3`, `aurora` 등 여러 모듈이 동시에 추가되면서 병합 충돌이 있었습니다.
- 현재는 양쪽 브랜치의 변경 사항을 모두 반영하여 코드를 통합했으며, 모든 모듈이 정상적으로 포함되어 있습니다.
- 특히 `eks` 모듈에 `vpc_id`와 `public_access_cidrs` 같은 필수 변수가 정확히 전달되도록 수정되었으니 참고 바랍니다.