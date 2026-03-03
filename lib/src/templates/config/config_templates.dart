String getAppConfigTemplate(String projectName) =>
    """
import 'package:$projectName/$projectName.dart';

class AppConfig {
  static String get baseUrl => dotenv.get('BASE_URL', fallback: 'https://api.example.com/');
  static bool get isDebug => dotenv.get('DEBUG', fallback: 'true') == 'true';
}
""";

String getAnalysisOptionsTemplate() => """
include: package:flutter_lints/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    - always_declare_return_types
    - always_require_non_null_named_parameters
    - annotate_overrides
    - avoid_init_to_null
    - avoid_null_checks_in_equality_operators
    - avoid_relative_lib_imports
    - avoid_return_types_on_setters
    - avoid_shadowing_type_parameters
    - avoid_single_cascade_in_expression_statements
    - avoid_types_as_parameter_names
    - avoid_unused_constructor_parameters
    - camel_case_extensions
    - camel_case_types
    - constant_identifier_names
    - curly_braces_in_flow_control_structures
    - empty_catches
    - empty_constructor_bodies
    - library_names
    - library_prefixes
    - no_duplicate_case_values
    - null_closures
    - omit_local_variable_types
    - prefer_adjacent_string_concatenation
    - prefer_collection_literals
    - prefer_conditional_assignment
    - prefer_contains
    - prefer_equal_for_default_values
    - prefer_final_fields
    - prefer_for_elements_to_map_fromIterable
    - prefer_function_declarations_over_variables
    - prefer_generic_function_type_aliases
    - prefer_if_null_operators
    - prefer_initializer_lists
    - prefer_inlined_adds
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_iterable_whereType
    - prefer_single_quotes
    - prefer_spread_collections
    - prefer_typing_uninitialized_variables
    - prefer_void_to_null
    - recursive_getters
    - slash_for_doc_comments
    - sort_constructors_first
    - sort_pub_dependencies
    - type_init_formals
    - unawaited_futures
    - unnecessary_const
    - unnecessary_getters_setters
    - unnecessary_lambdas
    - unnecessary_new
    - unnecessary_null_aware_assignments
    - unnecessary_null_in_if_null_operators
    - unnecessary_overrides
    - unnecessary_parenthesis
    - unnecessary_this
    - unrelated_type_equality_checks
    - use_function_type_aliases
    - use_rethrow_when_possible
    - valid_regexps
""";

String getGitignoreTemplate() => """
# Flutter/Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/

# Android
.gradle/
local.properties
*.kwks
*.keystore
*.jks
*.p12
*.apk
*.ap_
*.aab

# iOS
.generated/
*.log
*.mode1v3
*.mode2v3
*.perspectivev3
!default.mode1v3
!default.mode2v3
!default.perspectivev3
xcuserdata/
*.xccheckout
*.moved-aside
DerivedData/
*.hmap
*.ipa
*.xcuserstate
ios/Flutter/.last_build_id

# Environment
.env
.env.backup
.env.production

# IDE
.vscode/
.idea/
*.iml
*.iws
.project
.classpath
.settings/
""";

String getVSCodeSettingsTemplate() => """
{
  "dart.debugSdkLibraries": false,
  "dart.debugExternalPackageLibraries": false,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": "explicit",
    "source.organizeImports": "explicit"
  },
  "dart.previewFlutterUiGuides": true,
  "dart.flutterHotReloadOnSave": "manual",
  "dart.openDevTools": "flutter"
}
""";
