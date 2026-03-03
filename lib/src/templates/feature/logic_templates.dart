String getBlocTemplate(String projectName, String name, String namePascal) =>
    """
import 'package:$projectName/$projectName.dart';

part '${name}_event.dart';
part '${name}_state.dart';

class ${namePascal}Bloc extends HydratedBloc<${namePascal}Event, ${namePascal}State> {
  ${namePascal}Bloc() : super(${namePascal}Initial()) {
    on<${namePascal}Event>((event, emit) {});
  }

  @override
  ${namePascal}State? fromJson(Map<String, dynamic> json) => null;

  @override
  Map<String, dynamic>? toJson(${namePascal}State state) => null;
}
""";

String getEventTemplate(String name, String namePascal) =>
    """
part of '${name}_bloc.dart';

abstract class ${namePascal}Event {}
""";

String getStateTemplate(String name, String namePascal) =>
    """
part of '${name}_bloc.dart';

abstract class ${namePascal}State {}
class ${namePascal}Initial extends ${namePascal}State {}
class ${namePascal}Loading extends ${namePascal}State {}
class ${namePascal}Success extends ${namePascal}State {
  final dynamic data;
  ${namePascal}Success({this.data});
}
class ${namePascal}Error extends ${namePascal}State {
  final String message;
  ${namePascal}Error(this.message);
}
""";

String getCubitTemplate(String projectName, String name, String namePascal) =>
    """
import 'package:$projectName/$projectName.dart';

part '${name}_state.dart';

class ${namePascal}Cubit extends HydratedCubit<${namePascal}State> {
  ${namePascal}Cubit() : super(${namePascal}Initial());

  @override
  ${namePascal}State? fromJson(Map<String, dynamic> json) => null;

  @override
  Map<String, dynamic>? toJson(${namePascal}State state) => null;
}
""";

String getCubitStateTemplate(String name, String namePascal) =>
    """
part of '${name}_cubit.dart';

abstract class ${namePascal}State {}
class ${namePascal}Initial extends ${namePascal}State {}
class ${namePascal}Loading extends ${namePascal}State {}
class ${namePascal}Success extends ${namePascal}State {
  final dynamic data;
  ${namePascal}Success({this.data});
}
class ${namePascal}Error extends ${namePascal}State {
  final String message;
  ${namePascal}Error(this.message);
}
""";

String getRiverpodTemplate(
  String projectName,
  String name,
  String namePascal,
) =>
    """
import 'package:$projectName/$projectName.dart';

part '${name}_provider.g.dart';

@riverpod
class ${namePascal}Notifier extends _\$${namePascal}Notifier {
  @override
  AsyncValue build() {
    return const AsyncValue.data(null);
  }
}
""";

String getRiverpodStateTemplate(String name, String namePascal) =>
    """
part of '${name}_provider.dart';

// No separate state file needed for AsyncValue pattern
""";

String getGetXTemplate(String projectName, String name, String namePascal) =>
    """
import 'package:$projectName/$projectName.dart';

class ${namePascal}Controller extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _errorMessage.value.isNotEmpty;

  final _data = Rxn<dynamic>();
  dynamic get data => _data.value;
}
""";

String getGetXStateTemplate(String name, String namePascal) => """
// GetX usually doesn't use a separate state file by default
""";

String getProviderTemplate(
  String projectName,
  String name,
  String namePascal,
) =>
    """
import 'package:$projectName/$projectName.dart';

class ${namePascal}Provider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  dynamic _data;
  dynamic get data => _data;
}
""";

String getProviderStateTemplate(String name, String namePascal) => """
// For Provider, state is usually kept inside the ChangeNotifier
""";
