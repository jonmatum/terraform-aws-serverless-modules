#!/bin/bash
set -e

echo "🧪 Testing All Modules"
echo "======================"

# Test all modules can initialize
echo ""
echo "📦 Testing Module Initialization..."
for module in modules/*/; do
  module_name=$(basename "$module")
  echo -n "  Testing $module_name... "
  cd "$module"
  rm -rf .terraform .terraform.lock.hcl
  if terraform init -backend=false > /dev/null 2>&1 && terraform validate > /dev/null 2>&1; then
    echo "✅"
  else
    echo "❌ FAILED"
    exit 1
  fi
  cd - > /dev/null
done

# Test all examples can initialize
echo ""
echo "📦 Testing Example Initialization..."
for example in examples/*/; do
  example_name=$(basename "$example")
  echo -n "  Testing $example_name... "
  cd "$example"
  if terraform init > /dev/null 2>&1 && terraform validate > /dev/null 2>&1; then
    echo "✅"
  else
    echo "❌ FAILED"
    terraform validate
    exit 1
  fi
  cd - > /dev/null
done

echo ""
echo "✅ All modules and examples validated successfully!"
echo ""
echo "Summary:"
echo "  ✅ All modules can initialize"
echo "  ✅ All modules pass validation"
echo "  ✅ All examples can initialize"
echo "  ✅ All examples pass validation"
echo ""
echo "Ready for deployment! 🚀"
