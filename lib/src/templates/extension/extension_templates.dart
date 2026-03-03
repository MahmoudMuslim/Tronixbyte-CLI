String getContextExtensionsTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  /// Returns true if the current theme brightness is dark.
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  void goBack() => GoRouter.of(this).pop();
  void push(String location) => GoRouter.of(this).push(location);
  void replace(String location) => GoRouter.of(this).replace(location);
}
""";
