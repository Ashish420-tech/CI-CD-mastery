#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$HOME/CI-CD-mastery"
PROJECT="$ROOT/project-36-helm-application-packaging"
WORKFLOW="$ROOT/.github/workflows/project-36-helm-cicd.yml"

cd "$ROOT"

echo
echo "============================================================"
echo " PROJECT 36 - DEVSECOPS CI/CD CONFIGURATION"
echo "============================================================"

echo
echo "===== 1. VERIFY BRANCH ====="

BRANCH="$(git branch --show-current)"

echo "Branch: $BRANCH"

if [[ "$BRANCH" != "project-36-helm-application-packaging" ]]; then
    echo "ERROR: Wrong branch."
    exit 1
fi

echo
echo "===== 2. REMOVE LOCAL PRE-COMMIT CONFIG ====="

rm -f "$PROJECT/.pre-commit-config.yaml"

echo "Removed Project 36 local pre-commit configuration."

echo
echo "===== 3. RESTORE ACCIDENTAL UNRELATED FORMATTING ====="

git restore -- \
    project-24-compose-observability/README.md \
    project-26-compose-dependency-resilience/README.md \
    2>/dev/null || true

echo "Unrelated README changes restored."

echo
echo "===== 4. VERIFY INTENDED APPLICATION CHANGES ====="

grep -q '@app.get("/version")' \
    "$PROJECT/app/app.py"

grep -q 'ci_cd="github-actions"' \
    "$PROJECT/app/app.py"

grep -q 'test_application_version_endpoint' \
    "$PROJECT/tests/test_helm.py"

echo "Application /version endpoint: FOUND"
echo "Application test: FOUND"

echo
echo "===== 5. BACKUP WORKFLOW ====="

cp "$WORKFLOW" "${WORKFLOW}.backup.$(date +%Y%m%d%H%M%S)"

echo "Workflow backup created."

echo
echo "===== 6. REBUILD PROJECT 36 WORKFLOW ====="

cat > "$WORKFLOW" <<'YAML'
name: Project 36 - Helm CI/CD

on:
  push:
    branches:
      - project-36-helm-application-packaging
  pull_request:
    branches:
      - project-36-helm-application-packaging

permissions:
  contents: read
  id-token: write

env:
  AWS_REGION: ap-south-1
  ECR_REPOSITORY: ci-cd-mastery/applications
  EKS_CLUSTER: ci-cd-mastery-eks
  NAMESPACE: project-36
  RELEASE_NAME: project-36
  CHART_PATH: project-36-helm-application-packaging/chart/project-36-app
  IMAGE_NAME: project-36-helm-app

jobs:

  security:
    name: Secret and Git Security Scan
    runs-on: ubuntu-latest

    steps:
      - name: Checkout full Git history
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Gitleaks secret scan
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  test:
    name: Application and Helm Tests
    needs: security
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install test dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r project-36-helm-application-packaging/app/requirements.txt
          pip install pytest PyYAML

      - name: Run tests
        run: |
          pytest -q project-36-helm-application-packaging/tests

  helm:
    name: Helm Validation
    needs: test
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Helm
        uses: azure/setup-helm@v4
        with:
          version: v3.19.2

      - name: Helm lint
        run: |
          helm lint "$CHART_PATH"

      - name: Helm template
        run: |
          helm template "$RELEASE_NAME" "$CHART_PATH" \
            --namespace "$NAMESPACE" \
            --set image.repository="$IMAGE_NAME" \
            --set image.tag="${GITHUB_SHA}"

      - name: Helm package
        run: |
          helm package "$CHART_PATH"

  build:
    name: Build and Security Scan
    needs:
      - test
      - helm
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Build image
        run: |
          docker build \
            -t "$IMAGE_NAME:${GITHUB_SHA}" \
            project-36-helm-application-packaging/app

      - name: Trivy scan
        uses: aquasecurity/trivy-action@v0.36.0
        with:
          image-ref: "$IMAGE_NAME:${{ github.sha }}"
          severity: HIGH,CRITICAL
          ignore-unfixed: true
          exit-code: "1"

  deploy:
    name: Deploy Helm Release to EKS
    if: github.event_name == 'push'
    needs: build
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS through GitHub OIDC
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to ECR
        id: ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build and push immutable image
        env:
          REGISTRY: ${{ steps.ecr.outputs.registry }}
        run: |
          IMAGE="$REGISTRY/$ECR_REPOSITORY:$GITHUB_SHA"

          docker build \
            -t "$IMAGE" \
            project-36-helm-application-packaging/app

          docker push "$IMAGE"

          echo "IMAGE=$IMAGE" >> "$GITHUB_ENV"

      - name: Configure kubectl
        run: |
          aws eks update-kubeconfig \
            --region "$AWS_REGION" \
            --name "$EKS_CLUSTER"

      - name: Verify EKS access
        run: |
          kubectl get nodes

      - name: Setup Helm
        uses: azure/setup-helm@v4
        with:
          version: v3.19.2

      - name: Deploy Helm release
        run: |
          helm upgrade --install "$RELEASE_NAME" "$CHART_PATH" \
            --namespace "$NAMESPACE" \
            --create-namespace \
            --set image.repository="${IMAGE%:*}" \
            --set image.tag="${GITHUB_SHA}" \
            --set image.pullPolicy=IfNotPresent \
            --wait \
            --timeout 180s

      - name: Verify Helm release
        run: |
          helm status "$RELEASE_NAME" -n "$NAMESPACE"
          helm list -n "$NAMESPACE"

      - name: Verify Kubernetes rollout
        run: |
          kubectl rollout status \
            deployment/project-36 \
            -n "$NAMESPACE" \
            --timeout=180s

          kubectl get deployment -n "$NAMESPACE"
          kubectl get pods -n "$NAMESPACE" -o wide
          kubectl get service -n "$NAMESPACE"
          kubectl get endpoints -n "$NAMESPACE"

      - name: Verify deployed application
        run: |
          kubectl run project-36-smoke \
            -n "$NAMESPACE" \
            --rm \
            -i \
            --restart=Never \
            --image=curlimages/curl:8.12.1 \
            -- \
            curl -fsS \
            http://project-36.$NAMESPACE.svc.cluster.local/version
YAML

echo "Workflow rebuilt with Gitleaks security gate."

echo
echo "===== 7. VERIFY GITLEAKS STAGE ====="

grep -n -A12 '^  security:' "$WORKFLOW"

echo
echo "===== 8. VERIFY PIPELINE DEPENDENCY ====="

grep -n -A4 '^  test:' "$WORKFLOW"

echo
echo "===== 9. VALIDATE PROJECT 36 TESTS ====="

if [[ -x "$PROJECT/.venv/bin/python" ]]; then
    "$PROJECT/.venv/bin/python" -m pytest -q \
        "$PROJECT/tests"
else
    echo "WARNING: Project .venv not found."
    echo "Skipping local pytest."
fi

echo
echo "===== 10. HELM VALIDATION ====="

helm lint "$PROJECT/chart/project-36-app"

helm template project-36 \
    "$PROJECT/chart/project-36-app" \
    --namespace project-36 \
    --set image.repository=project-36-helm-app \
    --set image.tag=local-test \
    >/dev/null

echo "Helm lint/template: PASS"

echo
echo "===== 11. GIT STATUS ====="

git status --short

echo
echo "===== 12. FINAL DIFF ====="

git diff -- \
    "$WORKFLOW" \
    "$PROJECT/app/app.py" \
    "$PROJECT/tests/test_helm.py" \
    "$PROJECT/.pre-commit-config.yaml"

echo
echo "============================================================"
echo " CONFIGURATION COMPLETE"
echo "============================================================"

echo
echo "IMPORTANT:"
echo "Nothing has been committed."
echo "Nothing has been pushed."

echo
echo "Expected pipeline:"
echo
echo "  Gitleaks"
echo "      ↓"
echo "  pytest"
echo "      ↓"
echo "  Helm lint/template/package"
echo "      ↓"
echo "  Docker build + Trivy"
echo "      ↓"
echo "  ECR push"
echo "      ↓"
echo "  Helm → EKS"
echo "      ↓"
echo "  Rollout"
echo "      ↓"
echo "  /version smoke test"

echo
echo "Review git diff, then commit/push manually."
