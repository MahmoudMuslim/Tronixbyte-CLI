class MarketplaceModule {
  final String id;
  final String name;
  final String description;
  final List<String> dependencies;
  final List<String> devDependencies;
  final Map<String, String> files; // Path -> Content Template

  MarketplaceModule({
    required this.id,
    required this.name,
    required this.description,
    this.dependencies = const [],
    this.devDependencies = const [],
    this.files = const {},
  });
}
