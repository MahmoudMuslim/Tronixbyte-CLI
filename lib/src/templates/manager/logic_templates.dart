String getThemeTemplate(String projectName, String type, String logicDir) {
  switch (type) {
    case 'bloc':
    case 'cubit':
      return _getThemeCubitTemplate(projectName, logicDir);
    case 'getx':
      return _getThemeGetxTemplate(projectName, logicDir);
    case 'riverpod':
      return _getThemeRiverpodTemplate(projectName, logicDir);
    case 'provider':
      return _getThemeProviderTemplate(projectName, logicDir);
    default:
      return "";
  }
}

String _getThemeProviderTemplate(String projectName, String logicDir) =>
    """
import 'package:$projectName/$projectName.dart';
part 'theme_state.dart';
part 'theme_$logicDir.g.dart';

class ThemeProvider extends ChangeNotifier {
final ThemeState _themeState = ThemeState(themeMode: ThemeMode.system);

void updateThemeMode(ThemeMode themeMode) {
  _themeState.themeMode = themeMode;
  notifyListeners();
}
}
""";

String _getThemeRiverpodTemplate(String projectName, String logicDir) =>
    """
import 'package:$projectName/$projectName.dart';
part 'theme_state.dart';
part 'theme_$logicDir.g.dart';

final themeProvider = Provider<ThemeState>((ref) => ThemeState(themeMode: ThemeMode.system));
""";

String _getThemeGetxTemplate(String projectName, String logicDir) =>
    """
import 'package:$projectName/$projectName.dart';
part 'theme_state.dart';
part 'theme_$logicDir.g.dart';

class ThemeController extends GetxController {
final ThemeState _themeState = ThemeState(themeMode: ThemeMode.system);

void updateTheme(ThemeMode themeMode) {
  _themeState.themeMode = themeMode;
  Get.changeThemeMode(themeMode);
}
}
""";

String _getThemeCubitTemplate(String projectName, String logicDir) =>
    """
import 'package:$projectName/$projectName.dart';
part 'theme_state.dart';
part 'theme_$logicDir.g.dart';

class ThemeCubit extends HydratedCubit<ThemeState> {
ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.system));

void updateTheme(ThemeMode themMode) => emit(ThemeState(themeMode: themMode));

@override
ThemeState? fromJson(Map<String, dynamic> json) => ThemeState.fromJson(json);

@override
Map<String, dynamic>? toJson(ThemeState state) => state.toJson();
}
""";

String getLocaleTemplate(String projectName, String type, String logicDir) {
  switch (type) {
    case 'bloc':
    case 'cubit':
      return _getLocaleCubitTemplate(projectName, logicDir);
    case 'getx':
      return _getLocaleGetxTemplate(projectName, logicDir);
    case 'riverpod':
      return _getLocaleRiverpodTemplate(projectName, logicDir);
    case 'provider':
      return _getLocaleProviderTemplate(projectName, logicDir);
    default:
      return "";
  }
}

String _getLocaleProviderTemplate(String projectName, String logicDir) =>
    """
import 'package:$projectName/$projectName.dart';
part 'locale_state.dart';
part 'locale_$logicDir.g.dart';

class LocaleProvider extends ChangeNotifier {
final LocaleState _localeState = LocaleState(locale: Locale('en'));

  void updateLocale(Locale locale,BuildContext context) {
    _localeState.locale = locale;
    EasyLocalization.of(context)?.setLocale(locale);
  }
}
""";

String _getLocaleRiverpodTemplate(String projectName, String logicDir) =>
    """
import 'package:$projectName/$projectName.dart';
part 'locale_state.dart';
part 'locale_$logicDir.g.dart';
final localeProvider = Provider<LocaleState>((ref) => LocaleState(locale: Locale('en')));
""";

String _getLocaleGetxTemplate(String projectName, String logicDir) =>
    """
import 'package:$projectName/$projectName.dart';
part 'locale_state.dart';
part 'locale_$logicDir.g.dart';

class LocaleController extends GetxController {
  final LocaleState _localeState = LocaleState(locale: Locale('en'));

  void updateLocale(Locale locale,BuildContext context) {
    _localeState.locale = locale;
    EasyLocalization.of(context)?.setLocale(locale);
  }
}
""";

String _getLocaleCubitTemplate(String projectName, String logicDir) =>
    """
import 'package:$projectName/$projectName.dart';

part 'locale_state.dart';
part 'locale_$logicDir.g.dart';

class LocaleCubit extends HydratedCubit<LocaleState> {
  LocaleCubit() : super(const LocaleState(locale: Locale('en')));

  void updateLocale(Locale locale) => emit(LocaleState(locale: locale));

  @override
  LocaleState? fromJson(Map<String, dynamic> json) => LocaleState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(LocaleState state) => state.toJson();
}
""";

String getThemeStateTemplate(String stateType) =>
    """
part of 'theme_$stateType.dart';

@JsonSerializable()
@generateProps
class ThemeState extends Equatable {
${stateType == 'getx' ? """
  final Rx<ThemeMode> _themeMode;
  const ThemeState({required ThemeMode themeMode}):this._themeMode = themeMode.obs;
  
  ThemeMode get themeMode => _themeMode.value;
  set themeMode(ThemeMode value) => _themeMode.value = value;
  """ : """
  final ThemeMode themeMode;
  const ThemeState({required this.themeMode});
  """}

  List<Object?> get props => _\$props;

  factory ThemeState.fromJson(Map<String, dynamic> json) => _\$ThemeStateFromJson(json);
  Map<String, dynamic> toJson() => _\$ThemeStateToJson(this);
}
""";
String getLocaleStateTemplate(String stateType) =>
    """
part of 'locale_$stateType.dart';

@JsonSerializable()
@generateProps
class LocaleState extends Equatable {
${stateType == 'getx' ? """
  final Rx<Locale> _locale;
  const LocaleState({required Locale locale}):this._locale = locale.obs;
  
  Locale get locale => _locale.value;
  set locale(Locale value) => _locale.value = value;
  """ : """
  @LocaleConverter()
  final Locale locale;
  const LocaleState({required this.locale});
  """}

  List<Object?> get props => _\$props;

  factory LocaleState.fromJson(Map<String, dynamic> json) => _\$LocaleStateFromJson(json);
  Map<String, dynamic> toJson() => _\$LocaleStateToJson(this);
}

class LocaleConverter implements JsonConverter<Locale, String> {
  const LocaleConverter();

  @override
  Locale fromJson(String json) {
    final parts = json.split('_');
    return Locale(parts[0], parts.length > 1 ? parts[1] : null);
  }

  @override
  String toJson(Locale object) => object.toString();
}
""";
