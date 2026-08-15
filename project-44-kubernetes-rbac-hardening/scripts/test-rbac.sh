#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="project-44-rbac"

APP="system:serviceaccount:${NAMESPACE}:project-44-app"
VIEWER="system:serviceaccount:${NAMESPACE}:project-44-viewer"
OPERATOR="system:serviceaccount:${NAMESPACE}:project-44-operator"

PASS=0
FAIL=0

check() {
  local identity="$1"
  local verb="$2"
  local resource="$3"
  local expected="$4"
  local description="$5"

  set +e
  actual="$(kubectl auth can-i "$verb" "$resource" \
    --namespace="$NAMESPACE" \
    --as="$identity" 2>/dev/null)"
  rc=$?
  set -e

  if [[ "$actual" == "$expected" ]]; then
    echo "PASS | $description | expected=$expected actual=$actual"
    PASS=$((PASS + 1))
  else
    echo "FAIL | $description | expected=$expected actual=$actual"
    FAIL=$((FAIL + 1))
  fi
}

echo "=============================================="
echo "PROJECT 44 RBAC AUTHORIZATION TEST SUITE"
echo "=============================================="

echo
echo "===== APPLICATION IDENTITY ====="

check "$APP" get pods yes "app can read pods"
check "$APP" list pods yes "app can list pods"
check "$APP" watch pods yes "app can watch pods"
check "$APP" get services yes "app can read services"
check "$APP" get configmaps yes "app can read configmaps"

check "$APP" get secrets no "app cannot read secrets"
check "$APP" delete pods no "app cannot delete pods"
check "$APP" create deployments.apps no "app cannot create deployments"
check "$APP" create roles.rbac.authorization.k8s.io no "app cannot create roles"

echo
echo "===== VIEWER IDENTITY ====="

check "$VIEWER" get pods yes "viewer can read pods"
check "$VIEWER" list pods yes "viewer can list pods"
check "$VIEWER" watch pods yes "viewer can watch pods"
check "$VIEWER" get services yes "viewer can read services"
check "$VIEWER" get configmaps yes "viewer can read configmaps"
check "$VIEWER" get deployments.apps yes "viewer can read deployments"

check "$VIEWER" get secrets no "viewer cannot read secrets"
check "$VIEWER" update deployments.apps no "viewer cannot update deployments"
check "$VIEWER" delete pods no "viewer cannot delete pods"

echo
echo "===== OPERATOR IDENTITY ====="

check "$OPERATOR" get pods yes "operator can read pods"
check "$OPERATOR" list pods yes "operator can list pods"
check "$OPERATOR" get deployments.apps yes "operator can read deployments"
check "$OPERATOR" update deployments.apps yes "operator can update deployments"
check "$OPERATOR" patch deployments.apps yes "operator can patch deployments"
check "$OPERATOR" get configmaps yes "operator can read configmaps"

check "$OPERATOR" get secrets no "operator cannot read secrets"
check "$OPERATOR" create roles.rbac.authorization.k8s.io no "operator cannot create roles"
check "$OPERATOR" create rolebindings.rbac.authorization.k8s.io no "operator cannot create rolebindings"
check "$OPERATOR" delete pods no "operator cannot delete pods"

echo
echo "=============================================="
echo "RBAC TEST SUMMARY"
echo "=============================================="
echo "PASS: $PASS"
echo "FAIL: $FAIL"

if [[ "$FAIL" -ne 0 ]]; then
  echo
  echo "PROJECT 44 RBAC SECURITY: FAIL"
  exit 1
fi

echo
echo "PROJECT 44 RBAC SECURITY: PASS"
echo "=============================================="
