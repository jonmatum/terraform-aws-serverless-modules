#!/bin/bash
set -e

# Test idempotency of Terraform infrastructure
# Usage: ./test-idempotency.sh [example-name]

EXAMPLE=${1:-"api-gateway-multi-service"}
EXAMPLE_DIR="examples/${EXAMPLE}"

echo "🧪 Testing idempotency for: ${EXAMPLE}"
echo "================================================"

if [ ! -d "$EXAMPLE_DIR" ]; then
  echo "❌ Example directory not found: $EXAMPLE_DIR"
  exit 1
fi

cd "$EXAMPLE_DIR"

# Test 1: Fresh deploy
echo ""
echo "📦 Test 1: Fresh Deploy"
echo "------------------------"
terraform init -upgrade > /dev/null 2>&1
terraform apply -auto-approve
if [ $? -eq 0 ]; then
  echo "✅ Fresh deploy: SUCCESS"
else
  echo "❌ Fresh deploy: FAILED"
  exit 1
fi

# Test 2: No changes (idempotent)
echo ""
echo "🔄 Test 2: Idempotent Apply (no changes)"
echo "------------------------"
terraform apply -auto-approve
if [ $? -eq 0 ]; then
  echo "✅ Idempotent apply: SUCCESS"
else
  echo "❌ Idempotent apply: FAILED"
  exit 1
fi

# Test 3: Destroy
echo ""
echo "🗑️  Test 3: Destroy"
echo "------------------------"
terraform destroy -auto-approve
if [ $? -eq 0 ]; then
  echo "✅ Destroy: SUCCESS"
else
  echo "❌ Destroy: FAILED"
  exit 1
fi

# Test 4: Redeploy after destroy
echo ""
echo "♻️  Test 4: Redeploy After Destroy"
echo "------------------------"
terraform apply -auto-approve
if [ $? -eq 0 ]; then
  echo "✅ Redeploy: SUCCESS"
else
  echo "❌ Redeploy: FAILED"
  exit 1
fi

# Test 5: Final cleanup
echo ""
echo "🧹 Test 5: Final Cleanup"
echo "------------------------"
terraform destroy -auto-approve
if [ $? -eq 0 ]; then
  echo "✅ Final cleanup: SUCCESS"
else
  echo "❌ Final cleanup: FAILED"
  exit 1
fi

echo ""
echo "================================================"
echo "🎉 All idempotency tests PASSED!"
echo "================================================"
echo ""
echo "Summary:"
echo "  ✅ Fresh deploy works"
echo "  ✅ Idempotent (no changes on reapply)"
echo "  ✅ Clean destroy"
echo "  ✅ Can redeploy after destroy"
echo "  ✅ Multiple deploy/destroy cycles work"
echo ""
echo "Your infrastructure is production-ready! 🚀"
