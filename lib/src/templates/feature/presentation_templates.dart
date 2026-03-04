String getScreenTemplate(
  String projectName,
  String namePascal,
  String logicClass,
  String type,
) {
  String logicWrap = "";
  String bodyContent = "const ${namePascal}Body()";

  if (type == 'bloc' || type == 'cubit') {
    logicWrap =
        """
    BlocProvider(
      create: (context) => sl<$logicClass>(),
      child: const AppScaffold(
        body: $bodyContent,
      ),
    )""";
  } else if (type == 'getx') {
    logicWrap =
        """
    GetBuilder<$logicClass>(
      init: sl<$logicClass>(),
      builder: (_) => const AppScaffold(
        body: $bodyContent,
      ),
    )""";
  } else if (type == 'provider') {
    logicWrap =
        """
    ChangeNotifierProvider(
      create: (_) => sl<$logicClass>(),
      child: const AppScaffold(
        body: $bodyContent,
      ),
    )""";
  } else {
    logicWrap = "const AppScaffold(body: $bodyContent)";
  }

  return """
import 'package:$projectName/$projectName.dart';

class ${namePascal}Screen extends StatelessWidget {
  const ${namePascal}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return $logicWrap;
  }
}
""";
}

String getBodyTemplate(
  String projectName,
  String name,
  String namePascal,
  String logicClass,
  String type,
) {
  String builder = "";
  if (type == 'bloc' || type == 'cubit') {
    builder =
        """
    BlocBuilder<$logicClass, ${namePascal}State>(
      builder: (context, state) {
        return switch (state) {
          ${namePascal}Loading() => const AppShimmer(),
          ${namePascal}Error(message: final msg) => ErrorView(message: msg),
          ${namePascal}Success(data: final data) => _buildContent(context, data),
          _ => const EmptyView(title:'$namePascal'),
        };
      },
    )""";
  } else if (type == 'riverpod') {
    builder =
        """
    Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(${name}Provider);
        return state.when(
          loading: () => const AppShimmer(),
          error: (err, stack) => ErrorView(message: err.toString()),
          data: (data) => _buildContent(context, data));
      },
    )""";
  } else if (type == 'getx') {
    builder =
        """
    GetBuilder<$logicClass>(
      builder: (controller) {
        if (controller.isLoading) return const AppShimmer();
        if (controller.hasError) return ErrorView(message: controller.errorMessage);
        if (controller.data == null) return const EmptyView(title:'$namePascal');
        return _buildContent(context, controller.data!);
      },
    )""";
  } else if (type == 'provider') {
    builder =
        """
    Consumer<$logicClass>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const AppShimmer();
        if (provider.hasError) return ErrorView(message: provider.errorMessage);
        if (provider.data == null) return const EmptyView(title:'$namePascal');
        return _buildContent(context, provider.data!);
      },
    )""";
  }

  return """
import 'package:$projectName/$projectName.dart';

class ${namePascal}Body extends StatelessWidget {
  const ${namePascal}Body({super.key});

  @override
  Widget build(BuildContext context) {
    return $builder;
  }

  Widget _buildContent(BuildContext context, dynamic data) {
    return Center(
      child: Text(
        '$namePascal Feature: \$data',
        style: context.textTheme.headlineMedium,
      ));
  }
}
""";
}
