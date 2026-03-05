String getContextExtensionsTemplate(String projectName, String stateType) =>
    """
import 'package:$projectName/$projectName.dart';

extension ContextExtensions on BuildContext {
  ${stateType != 'getx' ? """
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  /// Returns true if the current theme brightness is dark.
  bool get isDarkMode => theme.brightness == Brightness.dark;
  """ : ''}
  ColorScheme get colorScheme => theme.colorScheme;
  
  void goBack() => GoRouter.of(this).pop();
}
""";
