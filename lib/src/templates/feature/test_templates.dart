String getBlocTestTemplate(String projectName, String namePascal) =>
    """
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:$projectName/$projectName.dart';
import 'package:mocktail/mocktail.dart';

class Mock${namePascal}Bloc extends MockBloc<${namePascal}Event, ${namePascal}State> implements ${namePascal}Bloc {}

void main() {
  group('${namePascal}Bloc', () {
    late ${namePascal}Bloc bloc;

    setUp(() {
      bloc = ${namePascal}Bloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state, isA<${namePascal}Initial>());
    });
  });
}
""";

String getCubitTestTemplate(String projectName, String namePascal) =>
    """
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:$projectName/$projectName.dart';
import 'package:mocktail/mocktail.dart';

class Mock${namePascal}Cubit extends MockCubit<${namePascal}State> implements ${namePascal}Cubit {}

void main() {
  group('${namePascal}Cubit', () {
    late ${namePascal}Cubit cubit;

    setUp(() {
      cubit = ${namePascal}Cubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state, isA<${namePascal}Initial>());
    });
  });
}
""";

String getRiverpodTestTemplate(
  String projectName,
  String name,
  String namePascal,
) =>
    """
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:$projectName/$projectName.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('${namePascal}Notifier', () {
    test('initial state is correct', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      final state = container.read(${name}Provider);
      expect(state, isA<${namePascal}State>());
    });
  });
}
""";

String getGetXTestTemplate(String projectName, String namePascal) =>
    """
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:$projectName/$projectName.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('${namePascal}Controller', () {
    late ${namePascal}Controller controller;

    setUp(() {
      controller = ${namePascal}Controller();
    });

    test('initial state is correct', () {
      // expect(controller.initialized, true);
    });
  });
}
""";

String getProviderTestTemplate(String projectName, String namePascal) =>
    """
import 'package:flutter_test/flutter_test.dart';
import 'package:$projectName/$projectName.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('${namePascal}Provider', () {
    late ${namePascal}Provider provider;

    setUp(() {
      provider = ${namePascal}Provider();
    });

    test('initial state is correct', () {
      // expect(provider.hasListeners, false);
    });
  });
}
""";

String getWidgetTestTemplate(String projectName, String namePascal) =>
    """
import 'package:flutter_test/flutter_test.dart';
import 'package:$projectName/$projectName.dart';

void main() {
  testWidgets('${namePascal}Screen displays correctly', (WidgetTester tester) async {
    // await tester.pumpWidget(const MaterialApp(home: ${namePascal}Screen()));
    // expect(find.text('$namePascal Body'), findsOneWidget);
  });
}
""";
