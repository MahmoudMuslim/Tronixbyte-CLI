String getPreCommitHookTemplate() => """
#!/bin/sh
# Tronixbyte CLI - Pre-commit hook

echo "🔍 Running static analysis..."
flutter analyze
if [ \$? -ne 0 ]; then
echo "❌ Analysis failed. Please fix issues before committing."
exit 1
fi

echo "🧪 Running tests..."
flutter test
if [ \$? -ne 0 ]; then
echo "❌ Tests failed. Please fix tests before committing."
exit 1
fi

echo "✅ All checks passed. Committing..."
exit 0
""";
