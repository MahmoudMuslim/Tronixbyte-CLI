import 'package:tools/tools.dart';

Future<void> runMarketplaceWizard() async {
  while (true) {
    printSection('Tronixbyte Module Marketplace');
    printInfo('Discover and install plug-and-play elite modules.');

    final List<String> moduleOptions = marketplaceRegistry
        .map((m) => '${m.name} - ${m.description}')
        .toList();
    final choice = selectOption(
      'Available Modules',
      moduleOptions,
      showBack: true,
    );

    if (choice == 'back' || choice == null) return;

    final index = int.tryParse(choice);
    if (index != null && index >= 1 && index <= marketplaceRegistry.length) {
      final selectedModule = marketplaceRegistry[index - 1];
      await _installModule(selectedModule);
    } else {
      printError('Invalid selection.');
    }
  }
}

Future<void> _installModule(MarketplaceModule module) async {
  printSection('Installing: ${module.name}');

  final confirm =
      (ask('Proceed with installation of "${module.name}"? (y/n)') ?? 'n')
          .toLowerCase() ==
      'y';
  if (!confirm) return;

  await loadingSpinner('Scaffolding module "${module.name}"', () async {
    // 1. Add Dependencies
    if (module.dependencies.isNotEmpty) {
      await runCommand('flutter', ['pub', 'add', ...module.dependencies]);
    }
    if (module.devDependencies.isNotEmpty) {
      await runCommand('flutter', [
        'pub',
        'add',
        '--dev',
        ...module.devDependencies,
      ]);
    }

    // 2. Write Files
    module.files.forEach((path, content) {
      final file = File(path);
      if (!file.parent.existsSync()) file.parent.createSync(recursive: true);
      file.writeAsStringSync('${content.trim()}\n');
      printInfo('Created: $path');
    });

    // 3. Auto-sync project
    await syncProject();
  });

  printSuccess('Module "${module.name}" installed successfully!');
  printInfo('👉 Tip: Check the generated files and customize them as needed.');
}
