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
String getGitPrTemplate() {
  return """
## Description
<!-- Describe your changes in detail -->

## Type of Change
- [ ] Feature (New functionality)
- [ ] Fix (Bug fix)
- [ ] Refactor (Code improvement)
- [ ] Docs (Documentation)
- [ ] Chore (Maintenance)

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
""";
}
