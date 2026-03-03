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
