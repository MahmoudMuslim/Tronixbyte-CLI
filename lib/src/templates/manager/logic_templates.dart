String getThemeTemplate(String projectName, String type) {
  switch (type) {
    case 'bloc':
    case 'cubit':
      return _getThemeCubitTemplate(projectName);
    case 'getx':
      return _getThemeGetxTemplate(projectName);
    case 'riverpod':
      return _getThemeRiverpodTemplate(projectName);
    case 'provider':
      return _getThemeProviderTemplate(projectName);
    default:
      return "";
  }
}

String _getThemeProviderTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';
part 'theme_state.dart';

class ThemeProvider extends ChangeNotifier {
final ThemeState _themeState = ThemeState();

bool get isDarkMode => _themeState.isDarkMode;

void setThemeMode(ThemeMode mode) {
  _themeState.isDarkMode = !_themeState.isDarkMode;
  notifyListeners();
}
}
""";

String _getThemeRiverpodTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
""";

String _getThemeGetxTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

part 'theme_state.dart';

class ThemeController extends GetxController {
final ThemeState _themeState = ThemeState();

bool get isDarkMode => _themeState.isDarkMode;

void toggleTheme() {
  _themeState.isDarkMode = !_themeState.isDarkMode;
  Get.changeThemeMode(_themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light);
}
}
""";

String _getThemeCubitTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

part 'theme_state.dart';

class ThemeCubit extends HydratedCubit<ThemeState> {
ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.system));

void updateTheme(ThemeMode mode) => emit(ThemeState(themeMode: mode));

@override
ThemeState? fromJson(Map<String, dynamic> json) => ThemeState.fromMap(json);

@override
Map<String, dynamic>? toJson(ThemeState state) => state.toMap();
}
""";

String getLocaleTemplate(String projectName, String type) {
  switch (type) {
    case 'bloc':
    case 'cubit':
      return """
import 'package:$projectName/$projectName.dart';

part 'locale_state.dart';

class LocaleCubit extends HydratedCubit<LocaleState> {
  LocaleCubit() : super(const LocaleState(locale: Locale('en')));

  void updateLocale(Locale locale) => emit(LocaleState(locale: locale));

  @override
  LocaleState? fromJson(Map<String, dynamic> json) => LocaleState.fromMap(json);

  @override
  Map<String, dynamic>? toJson(LocaleState state) => state.toMap();
}
""";
    case 'getx':
      return """
import 'package:$projectName/$projectName.dart';
part 'locale_state.dart';

class LocaleController extends GetxController {
  final LocaleState _localeState = LocaleState();

  void changeLocale(Locale locale,BuildContext context) {
    _localeState.locale = locale;
    EasyLocalization.of(context)?.setLocale(locale);
  }
}
""";
    case 'provider':
      return """
import 'package:$projectName/$projectName.dart';
part 'locale_state.dart';

class LocaleProvider extends ChangeNotifier {
  final LocaleState _localeState = LocaleState();

  void changeLocale(Locale locale,BuildContext context) {
    _localeState.locale = locale;
    EasyLocalization.of(context)?.setLocale(locale);
  }
}
""";
    default:
      return "";
  }
}

String getThemeStateGenericTemplate(String stateType) {
  return """
part of 'theme_$stateType.dart';

class ThemeState extends Equatable {
  ${stateType == 'getx' ? """
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;
  set isDarkMode (bool value) => _isDarkMode.value = value;
  """ : """
  ThemeMode themeMode = ThemeMode.system;
  """}

  @override
  List<Object?> get props => [themeMode];

  Map<String, dynamic> toMap() => {'themeMode': themeMode.index};
  
  factory ThemeState.fromMap(Map<String, dynamic> map) {
    return ThemeState(
      themeMode: ThemeMode.values[map['themeMode'] ?? 0]);
  }  
}
""";
}

String getThemeStateTemplate(String stateType) =>
    """
part of 'theme_$stateType.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  const ThemeState({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];

  Map<String, dynamic> toMap() => {'themeMode': themeMode.index};
  
  factory ThemeState.fromMap(Map<String, dynamic> map) {
    return ThemeState(
      themeMode: ThemeMode.values[map['themeMode'] ?? 0]);
  }
}
""";

String getLocaleStateGenericTemplate(String stateType) {
  return """
part of 'locale_$stateType.dart';

class LocaleState extends Equatable {
${stateType == 'getx' ? """
  final Locale _locale = Locale('en').obs;
  Locale get locale => _locale.value;
  set locale (Locale value) => _locale.value = value;
  """ : """
  Locale locale = Locale('en');
  """}
  
  @override
  List<Object?> get props => [locale];

  Map<String, dynamic> toMap() => {'languageCode': locale.languageCode};

  factory LocaleState.fromMap(Map<String, dynamic> map) {
    return LocaleState(
      locale: Locale(map['languageCode'] ?? 'en'));
  }
}
""";
}

String getLocaleStateTemplate(String stateType) =>
    """
part of 'locale_$stateType.dart';

class LocaleState extends Equatable {
  final Locale locale;
  const LocaleState({required this.locale});

  @override
  List<Object?> get props => [locale];

  Map<String, dynamic> toMap() => {'languageCode': locale.languageCode};

  factory LocaleState.fromMap(Map<String, dynamic> map) {
    return LocaleState(
      locale: Locale(map['languageCode'] ?? 'en'));
  }
}
""";
