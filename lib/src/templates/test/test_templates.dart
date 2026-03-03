String getWidgetTestsTemplate(String projectName, String className) =>
    """
import 'package:flutter_test/flutter_test.dart';
import 'package:$projectName/$projectName.dart';

void main() {
  testWidgets('$className should render correctly', (tester) async {
    // Scaffold the screen wrapped in standard app infrastructure
    await tester.pumpWidget(const MaterialApp(home: $className()));
    
    // Basic verification
    expect(find.byType($className), findsOneWidget);
  });
}
""";

String getScaffoldGoldenTestsTemplate() => """
# 🖼️ Golden Tests (Visual Regression)
This directory contains golden image comparisons.
Run goldens via: `flutter test --update-goldens`
""";

String getGenerateIntegrationTemplate(String name, String projectName) =>
    """
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:$projectName/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('${name[0].toUpperCase()}${name.substring(1)} Flow Test', () {
    testWidgets('Complete user journey for $name', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Implement your automated flow here
      // await tester.tap(find.byType(AppButton));
      // await tester.pumpAndSettle();
    });
  });
}
""";

String getGoldenTestTemplate(
  String projectName,
  String screenNamePascal,
  String screenName,
) =>
    """
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alchemist/alchemist.dart';
import 'package:$projectName/$projectName.dart';

void main() {
  group('$screenNamePascal Golden Tests', () {
    goldenTest(
      'renders correctly on mobile',
      fileName: '${screenName}_mobile',
      builder: () => const GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'Light Mode',
            child: $screenNamePascal(),
          ),
          GoldenTestScenario(
            name: 'Dark Mode',
            child: Theme(
              data: ThemeData.dark(),
              child: $screenNamePascal(),
            ),
          ),
        ],
      ),
    );
  });
}
""";
