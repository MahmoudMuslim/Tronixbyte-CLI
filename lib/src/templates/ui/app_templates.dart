String getMainTemplate(
  String projectName,
  bool enableNetwork,
  String stateType,
) =>
    """
import 'package:$projectName/$projectName.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ${enableNetwork ? """// Load Environment Variables
  await dotenv.load(fileName: ".env");""" : ''}

  // Dependency Injection
  await setupInjection();
${stateType == 'bloc' || stateType == 'cubit' ? """
  // Initialize Hydrated Storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getApplicationDocumentsDirectory()).path));
        """ : ""}

  // Initialize Localization
  await EasyLocalization.ensureInitialized();
  ${stateType == 'bloc' || stateType == 'cubit' ? """
  // Bloc Observer\nBloc.observer = MyBlocObserver();""" : ''}

  runApp(
    ${stateType == 'riverpod' ? 'ProviderScope(child: ' : ''}
    BetterFeedback(
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          child: const MyApp(),
        ),
      ),
    )
    ${stateType == 'riverpod' ? ')' : ''});
}
""";

String getMainAppTemplate(String projectName, String stateType) {
  String materialApp;
  switch (stateType) {
    case 'bloc':
    case 'cubit':
      materialApp = """
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<ThemeCubit>()),
        BlocProvider(create: (context) => sl<LocaleCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: LocaleKeys.app_title.tr(),
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.themeMode,
            builder: (context, child) {
              child = DevicePreview.appBuilder(context, child);
              Intl.defaultLocale = context.locale.toString();
              return child;
            },
          );
        },
      ));""";
      break;
    case 'getx':
      materialApp = """
    return GetBuilder<ThemeController>(
      init: sl<ThemeController>(),
      builder: (logic) => GetMaterialApp.router(
      title: LocaleKeys.app_title.tr(),
      debugShowCheckedModeBanner: false,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      locale: context.locale,
      fallbackLocale: const Locale('en'),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: logic.state.themeMode,
      builder: (context, child) {
        child = DevicePreview.appBuilder(context, child);
        Intl.defaultLocale = context.locale.toString();
        return child;
      },
    ));""";
      break;
    case 'riverpod':
      materialApp = """
    return Consumer(
      builder: (context, ref, child) {
        final themeMode = ref.watch(themeProvider).themeMode;
        return MaterialApp.router(
          title: LocaleKeys.app_title.tr(),
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          builder: (context, child) {
            child = DevicePreview.appBuilder(context, child);
            Intl.defaultLocale = context.locale.toString();
            return child;
          });
      });""";
      break;
    case 'provider':
      materialApp = """
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<ThemeProvider>()),
        ChangeNotifierProvider(create: (_) => sl<LocaleProvider>()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: LocaleKeys.app_title.tr(),
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.state.themeMode,
            builder: (context, child) {
              child = DevicePreview.appBuilder(context, child);
              Intl.defaultLocale = context.locale.toString();
              return child;
            },
          );
        },
      ));""";
      break;
    default:
      materialApp = """
    return MaterialApp.router(
      title: LocaleKeys.app_title.tr(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        child = DevicePreview.appBuilder(context, child);
        Intl.defaultLocale = context.locale.toString();
        return child;
      });""";
  }

  return """
import 'package:$projectName/$projectName.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    $materialApp
  }
}
""";
}

String getRouterTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

part 'router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@TypedGoRoute<SplashRoute>(path: '/',name: 'splash')
class SplashRoute extends GoRouteData with \$SplashRoute{
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashScreen();
}

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: \$appRoutes,
);
""";

String getAppScaffoldTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar != null ? PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: appBar!,
      ) : null,
      body: SafeArea(child: body),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton);
  }
}
""";

String getBlocObserverTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    log('onCreate -- \${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log('onChange -- \${bloc.runtimeType}, \$change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log('onError -- \${bloc.runtimeType}, \$error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    log('onClose -- \${bloc.runtimeType}');
  }
}
""";

String getAppThemeTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue);
}
""";

String getAppFlavorTemplate(String projectName, String flavor) {
  return """
import 'package:$projectName/$projectName.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();

// Load flavor-specific .env
try {
  await dotenv.load(fileName: '.env.$flavor');
} catch (_) {
  // Fallback if file doesn't exist
}

runApp(const App());
}
""";
}
