#!/bin/bash

# =============================================================================
# ECR 최신 이미지 태그 자동 업데이트 스크립트 (리뷰 서비스)
# =============================================================================

set -e  # 에러 발생시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로깅 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 스크립트 시작
echo "=================================================="
echo "🚀 ECR 최신 이미지 태그 자동 업데이트 스크립트"
echo "=================================================="

# 1. AWS CLI 설정 확인
log_info "AWS CLI 설정 확인 중..."
if ! aws configure list >/dev/null 2>&1; then
    log_error "AWS CLI가 설정되지 않았습니다."
    exit 1
fi

# 2. ECR 리포지토리 설정
ECR_REGION="ap-northeast-2"
ECR_REPO="mapzip-dev-ecr-review"
REVIEW_YAML_PATH="Infra/argocd/service-review/review.yaml"

log_info "ECR 리포지토리: $ECR_REPO (리전: $ECR_REGION)"

# 3. 파일 존재 확인
if [ ! -f "$REVIEW_YAML_PATH" ]; then
    log_error "파일을 찾을 수 없습니다: $REVIEW_YAML_PATH"
    exit 1
fi

# 4. ECR에서 최신 이미지 태그 가져오기
log_info "ECR에서 최신 이미지 태그 조회 중..."
LATEST_TAG=$(aws ecr describe-images \
    --repository-name "$ECR_REPO" \
    --region "$ECR_REGION" \
    --query 'sort_by(imageDetails,&imagePushedAt)[-1].imageTags[0]' \
    --output text 2>/dev/null)

if [ "$LATEST_TAG" = "None" ] || [ -z "$LATEST_TAG" ]; then
    log_error "ECR에서 이미지 태그를 가져올 수 없습니다."
    exit 1
fi

log_success "ECR 최신 이미지 태그: $LATEST_TAG"

# 5. 현재 이미지 태그 확인
log_info "현재 설정된 이미지 태그 확인 중..."
CURRENT_TAG=$(grep -o 'mapzip-dev-ecr-review:[a-zA-Z0-9]*' "$REVIEW_YAML_PATH" | cut -d':' -f2)

if [ -z "$CURRENT_TAG" ]; then
    log_error "현재 이미지 태그를 찾을 수 없습니다."
    exit 1
fi

log_info "현재 이미지 태그: $CURRENT_TAG"

# 6. 태그 비교
if [ "$CURRENT_TAG" = "$LATEST_TAG" ]; then
    log_warning "이미지 태그가 이미 최신입니다 ($LATEST_TAG). 업데이트가 필요하지 않습니다."
    exit 0
fi

# 7. ECR에서 현재 태그 존재 여부 확인
log_info "ECR에서 현재 태그($CURRENT_TAG) 존재 여부 확인 중..."
CURRENT_TAG_EXISTS=$(aws ecr describe-images \
    --repository-name "$ECR_REPO" \
    --region "$ECR_REGION" \
    --image-ids imageTag="$CURRENT_TAG" \
    --query 'imageDetails[0].imageTags[0]' \
    --output text 2>/dev/null || echo "None")

if [ "$CURRENT_TAG_EXISTS" = "None" ]; then
    log_warning "⚠️  현재 태그($CURRENT_TAG)가 ECR에 존재하지 않습니다!"
    log_info "이것이 ImagePullBackOff 오류의 원인일 수 있습니다."
else
    log_info "현재 태그($CURRENT_TAG)는 ECR에 존재합니다."
fi

# 8. 백업 생성
log_info "백업 생성 중..."
BACKUP_PATH="${REVIEW_YAML_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$REVIEW_YAML_PATH" "$BACKUP_PATH"
log_success "백업 생성 완료: $BACKUP_PATH"

# 9. 이미지 태그 업데이트
log_info "이미지 태그 업데이트 중... ($CURRENT_TAG → $LATEST_TAG)"
if sed -i.tmp "s|mapzip-dev-ecr-review:$CURRENT_TAG|mapzip-dev-ecr-review:$LATEST_TAG|g" "$REVIEW_YAML_PATH"; then
    rm -f "${REVIEW_YAML_PATH}.tmp"  # macOS sed 임시 파일 제거
    log_success "이미지 태그 업데이트 완료!"
else
    log_error "이미지 태그 업데이트 실패"
    exit 1
fi

# 10. 변경사항 확인
log_info "변경사항 확인 중..."
NEW_TAG=$(grep -o 'mapzip-dev-ecr-review:[a-zA-Z0-9]*' "$REVIEW_YAML_PATH" | cut -d':' -f2)
if [ "$NEW_TAG" = "$LATEST_TAG" ]; then
    log_success "✅ 변경 확인됨: $CURRENT_TAG → $NEW_TAG"
else
    log_error "❌ 변경사항 확인 실패"
    exit 1
fi

# 11. ECR 이미지 정보 표시
log_info "ECR에서 선택된 이미지 정보:"
aws ecr describe-images \
    --repository-name "$ECR_REPO" \
    --region "$ECR_REGION" \
    --image-ids imageTag="$LATEST_TAG" \
    --query 'imageDetails[0].{Tag:imageTags[0],Size:imageSizeInBytes,Pushed:imagePushedAt}' \
    --output table

# 12. Git 변경사항 표시
log_info "Git 변경사항:"
git diff --no-color "$REVIEW_YAML_PATH" | head -10

# 13. 자동 커밋 여부 묻기
echo ""
read -p "🤔 변경사항을 자동으로 커밋하고 푸시하시겠습니까? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 14. Git 커밋 및 푸시
    log_info "Git 커밋 및 푸시 중..."
    
    git add "$REVIEW_YAML_PATH"
    
    COMMIT_MESSAGE="fix: 리뷰 서비스 이미지 태그 ECR 최신으로 자동 업데이트

- 이미지 태그 $CURRENT_TAG → $LATEST_TAG 업데이트
- ECR 최신 이미지로 자동 동기화
- ImagePullBackOff 오류 방지

🤖 Auto-updated by ECR sync script

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

    if git commit -m "$COMMIT_MESSAGE"; then
        log_success "커밋 완료!"
        
        # 푸시할 브랜치 선택
        CURRENT_BRANCH=$(git branch --show-current)
        echo ""
        echo "현재 브랜치: $CURRENT_BRANCH"
        read -p "🚀 어느 브랜치로 푸시하시겠습니까? (dev/current): " PUSH_TARGET
        
        if [ "$PUSH_TARGET" = "dev" ] || [ -z "$PUSH_TARGET" ]; then
            PUSH_BRANCH="dev"
        else
            PUSH_BRANCH="$CURRENT_BRANCH"
        fi
        
        log_info "$PUSH_BRANCH 브랜치로 푸시 중..."
        if git push origin HEAD:$PUSH_BRANCH; then
            log_success "✅ 푸시 완료! ArgoCD가 자동으로 배포를 시작합니다."
            log_info "🔄 약 2-3분 후에 https://api.mapzip.shop/review/health 에서 상태를 확인하세요."
        else
            log_error "❌ 푸시 실패"
            exit 1
        fi
    else
        log_error "❌ 커밋 실패"
        exit 1
    fi
else
    log_info "수동 커밋을 원하시면 다음 명령어를 사용하세요:"
    echo ""
    echo "git add $REVIEW_YAML_PATH"
    echo "git commit -m 'fix: 리뷰 서비스 이미지 태그 $CURRENT_TAG → $LATEST_TAG 업데이트'"
    echo "git push origin HEAD:dev"
fi

echo ""
echo "=================================================="
log_success "🎉 ECR 최신 이미지 태그 동기화 완료!"
echo "=================================================="

# 15. 사용 가능한 모든 태그 표시 (참고용)
echo ""
log_info "📋 ECR에서 사용 가능한 모든 이미지 태그 (최신 10개):"
aws ecr describe-images \
    --repository-name "$ECR_REPO" \
    --region "$ECR_REGION" \
    --query 'sort_by(imageDetails,&imagePushedAt)[-10:].{Tag:imageTags[0],Pushed:imagePushedAt}' \
    --output table