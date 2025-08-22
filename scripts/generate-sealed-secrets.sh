#!/bin/bash

echo "========================================"
echo "Sealed Secrets Generator Script"
echo "========================================"

# Configuration
NAMESPACE="service-platform"
CONTROLLER_NAMESPACE="kube-system"
REGION="ap-northeast-2"
CLUSTER_NAME="mapzip-dev-eks"
AWS_PROFILE="lt4"

# SSM Parameter Store paths
GITHUB_USERNAME_PARAM="/mapzip/config-server/github-username"
GITHUB_TOKEN_PARAM="/mapzip/config-server/github-token"
ENCRYPT_KEY_PARAM="/mapzip/config-server/encrypt-key"
GOOGLE_VISION_API_KEY_PARAM="/mapzip/review/google-vision-api-key"

# Output file
OUTPUT_FILE="../argocd/platform/sealed-secrets.yaml"

echo "Checking prerequisites..."

# AWS Configuration
AWS_PROFILE="lt4"
REGION="ap-northeast-2"
CLUSTER_NAME="mapzip-dev-eks"

# Setup AWS Profile and kubeconfig
echo "🔧 Setting up AWS connection..."
export AWS_PROFILE="$AWS_PROFILE"

echo "Updating kubeconfig..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Verify AWS account
CURRENT_ACCOUNT=$(aws sts get-caller-identity --query 'Account' --output text 2>/dev/null)
EXPECTED_ACCOUNT="061039804626"

if [ "$CURRENT_ACCOUNT" != "$EXPECTED_ACCOUNT" ]; then
    echo "❌ AWS account verification failed!"
    echo "   Current: $CURRENT_ACCOUNT"
    echo "   Expected: $EXPECTED_ACCOUNT (mapzip team account)"
    echo "   Please check AWS profile: $AWS_PROFILE"
    exit 1
fi

echo "✅ AWS team account verified: $CURRENT_ACCOUNT"
echo "✅ Kubeconfig updated for cluster: $CLUSTER_NAME"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    exit 1
fi

# Check if kubeseal is available
if ! command -v kubeseal &> /dev/null; then
    echo "Error: kubeseal is not installed or not in PATH"
    echo "Install with: brew install kubeseal"
    exit 1
fi

# Check if aws cli is available
if ! command -v aws &> /dev/null; then
    echo "Error: aws cli is not installed or not in PATH"
    exit 1
fi

# Check if helm is available
if ! command -v helm &> /dev/null; then
    echo "Error: helm is not installed or not in PATH"
    echo "Install with: brew install helm"
    exit 1
fi

# Check if sealed-secrets controller is running
echo "Checking Sealed Secrets Controller..."
CONTROLLER_COUNT=$(kubectl get deployment -n $CONTROLLER_NAMESPACE -l app.kubernetes.io/name=sealed-secrets --no-headers 2>/dev/null | wc -l)
if [ "$CONTROLLER_COUNT" -eq 0 ]; then
    echo "⚠️  Sealed Secrets Controller not found. Installing..."
    
    # Add Sealed Secrets Helm repository
    echo "Adding Sealed Secrets Helm repository..."
    helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
    helm repo update
    
    # Install Sealed Secrets Controller
    echo "Installing Sealed Secrets Controller..."
    helm upgrade --install sealed-secrets sealed-secrets/sealed-secrets \
        --namespace $CONTROLLER_NAMESPACE \
        --version 2.15.4 \
        --wait \
        --timeout 300s
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install Sealed Secrets Controller"
        exit 1
    fi
    
    echo "✅ Sealed Secrets Controller installed successfully!"
else
    echo "✅ Sealed Secrets Controller already installed"
fi

# Wait for controller to be ready
echo "Waiting for controller to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment -l app.kubernetes.io/name=sealed-secrets -n $CONTROLLER_NAMESPACE

echo "Fetching secrets from AWS SSM Parameter Store..."

# Get GitHub credentials from SSM
GITHUB_USERNAME=$(aws ssm get-parameter --region $REGION --name "$GITHUB_USERNAME_PARAM" --query 'Parameter.Value' --output text 2>/dev/null)
GITHUB_TOKEN=$(aws ssm get-parameter --region $REGION --name "$GITHUB_TOKEN_PARAM" --with-decryption --query 'Parameter.Value' --output text 2>/dev/null)

if [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GitHub credentials not found in SSM Parameter Store"
    echo "Please run step 2️⃣ from SEALED_SECRETS_SIMPLE.md first"
    exit 1
fi

# Get encrypt key from SSM
ENCRYPT_KEY=$(aws ssm get-parameter --region $REGION --name "$ENCRYPT_KEY_PARAM" --with-decryption --query 'Parameter.Value' --output text 2>/dev/null)

# Get Google Vision API key from SSM
GOOGLE_VISION_API_KEY=$(aws ssm get-parameter --region $REGION --name "$GOOGLE_VISION_API_KEY_PARAM" --with-decryption --query 'Parameter.Value' --output text 2>/dev/null)

echo "Creating namespace if not exists..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "Generating Sealed Secrets..."

# Create temporary files
GIT_SECRET_TEMP=$(mktemp)
ENCRYPT_SECRET_TEMP=$(mktemp)
GOOGLE_VISION_SECRET_TEMP=$(mktemp)

# Generate Git Secret
kubectl create secret generic config-server-git-secret \
    --namespace=$NAMESPACE \
    --from-literal=username="$GITHUB_USERNAME" \
    --from-literal=token="$GITHUB_TOKEN" \
    --dry-run=client -o yaml | \
kubeseal \
    --controller-name sealed-secrets \
    --controller-namespace $CONTROLLER_NAMESPACE \
    --scope namespace-wide \
    --format yaml > "$GIT_SECRET_TEMP"

if [ $? -ne 0 ]; then
    echo "❌ Failed to generate git secret"
    rm -f "$GIT_SECRET_TEMP" "$ENCRYPT_SECRET_TEMP"
    exit 1
fi

# Generate Encrypt Secret (if encrypt key exists)
if [ -n "$ENCRYPT_KEY" ]; then
    echo "Generating encrypt secret..."
    kubectl create secret generic config-server-encrypt-secret \
        --namespace=$NAMESPACE \
        --from-literal=encrypt-key="$ENCRYPT_KEY" \
        --dry-run=client -o yaml | \
    kubeseal \
        --controller-name sealed-secrets \
        --controller-namespace $CONTROLLER_NAMESPACE \
        --scope namespace-wide \
        --format yaml > "$ENCRYPT_SECRET_TEMP"

    if [ $? -ne 0 ]; then
        echo "❌ Failed to generate encrypt secret"
        rm -f "$GIT_SECRET_TEMP" "$ENCRYPT_SECRET_TEMP"
        exit 1
    fi
else
    echo "⚠️  Encrypt key not found in SSM - skipping encrypt secret generation"
fi

# Generate Google Vision Secret (if API key exists)
if [ -n "$GOOGLE_VISION_API_KEY" ]; then
    echo "Generating Google Vision API secret..."
    kubectl create secret generic google-cloud-vision-secret \
        --namespace=service-review \
        --from-literal=api-key="$GOOGLE_VISION_API_KEY" \
        --dry-run=client -o yaml | \
    kubeseal \
        --controller-name sealed-secrets \
        --controller-namespace $CONTROLLER_NAMESPACE \
        --scope namespace-wide \
        --format yaml > "$GOOGLE_VISION_SECRET_TEMP"

    if [ $? -ne 0 ]; then
        echo "❌ Failed to generate Google Vision secret"
        rm -f "$GIT_SECRET_TEMP" "$ENCRYPT_SECRET_TEMP" "$GOOGLE_VISION_SECRET_TEMP"
        exit 1
    fi
else
    echo "⚠️  Google Vision API key not found in SSM - skipping Google Vision secret generation"
fi

# Combine secrets into one file
cat > "$OUTPUT_FILE" << EOF
# Config Server Sealed Secrets
# Generated by: generate-sealed-secrets.sh
# Date: $(date)

EOF

# Add Git Secret
echo "# Config Server Git Secret (SealedSecret)" >> "$OUTPUT_FILE"
cat "$GIT_SECRET_TEMP" >> "$OUTPUT_FILE"

# Add Encrypt Secret if it exists
if [ -n "$ENCRYPT_KEY" ]; then
    echo "" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "# Config Server Encrypt Secret (SealedSecret)" >> "$OUTPUT_FILE"
    cat "$ENCRYPT_SECRET_TEMP" >> "$OUTPUT_FILE"
fi

# Add Google Vision Secret if it exists
if [ -n "$GOOGLE_VISION_API_KEY" ]; then
    echo "" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "# Google Cloud Vision API Secret (SealedSecret)" >> "$OUTPUT_FILE"
    cat "$GOOGLE_VISION_SECRET_TEMP" >> "$OUTPUT_FILE"
fi

# Cleanup
rm -f "$GIT_SECRET_TEMP" "$ENCRYPT_SECRET_TEMP" "$GOOGLE_VISION_SECRET_TEMP"

echo "✅ Sealed secrets generated successfully!"
echo ""
echo "Generated file: $OUTPUT_FILE"
echo ""
echo "Generated secrets:"
echo "  - config-server-git-secret (GitHub credentials)"
if [ -n "$ENCRYPT_KEY" ]; then
    echo "  - config-server-encrypt-secret (Encryption key)"
fi
if [ -n "$GOOGLE_VISION_API_KEY" ]; then
    echo "  - google-cloud-vision-secret (Google Vision API key)"
fi
echo ""
echo "Next steps:"
echo "1. Follow step 6️⃣ from SEALED_SECRETS_SIMPLE.md (Git commit)"
echo "2. ArgoCD will automatically apply the secrets"
echo ""
echo "To verify secrets manually:"
echo "  kubectl get sealedsecrets -n $NAMESPACE"
echo "  kubectl get secrets -n $NAMESPACE"
