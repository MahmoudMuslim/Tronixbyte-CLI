String getRouteSnippedTemplate(String name, String namePascal) =>
    """


@TypedGoRoute<${namePascal}Route>(path: '/$name', name: '$name')
class ${namePascal}Route extends GoRouteData with \$${namePascal}Route {
  const ${namePascal}Route();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ${namePascal}Screen();
}""";
