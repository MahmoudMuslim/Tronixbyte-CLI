String getAITranslatorPromptTemplate(String targetLang, String enContent) {
  return """
    You are a professional mobile app translator. 
    Translate the following JSON map from English to language code: $targetLang.
    Maintain the same JSON keys. Only translate the values.
    Keep technical terms like "ID", "URL", or placeholders like "{name}" unchanged.
    Output ONLY the raw JSON string.
    
    Source JSON:
    $enContent
    """;
}

String getAIFeatureBluePrinterTemplate(
  String description,
  String projectName,
  String logicType,
) {
  return """
    You are an elite Flutter Architect specialized in Clean Architecture. 
    Analyze this feature description: "$description"
    
    Generate a structured JSON blueprint for a Clean Architecture feature in a Flutter app named "$projectName".
    The feature MUST support "$logicType" for state management.
    
    Requirements:
    1. Identify the core Entity name (PascalCase).
    2. Identify the Feature name (snake_case).
    3. Define Entity fields (name and type).
    4. List necessary DataSources (Local/Remote).
    5. List necessary Repository methods.
    6. List necessary UseCases.
    7. Identify required external dependencies (pub.dev packages).
    8. Generate high-quality Dart code for the implementation of the RepositoryImpl and UseCases.
    
    Output ONLY a raw JSON object with this exact structure:
    {
      "feature_name": "feature_name",
      "entity_name": "EntityName",
      "fields": [{"name": "id", "type": "String"}, {"name": "title", "type": "String"}],
      "methods": ["getSomething", "saveSomething"],
      "usecases": ["GetSomethingUseCase", "SaveSomethingUseCase"],
      "dependencies": ["dio", "intl"],
      "implementations": {
        "repository_impl": "DART_CODE_FOR_REPO_IMPL",
        "usecase_GetSomethingUseCase": "DART_CODE_FOR_UC"
      },
      "summary": "Short architectural summary"
    }
    """;
}
