/// Gemini API constants and configuration (FREE MODELS ONLY)
class GeminiConstants {
  GeminiConstants._();

  /// ✅ Default FREE model (FAST & STABLE)
  static const String defaultModel = 'gemini-1.5-flash';

  /// ✅ Flash model (same as default, free tier)
  static const String flashModel = 'gemini-1.5-flash';

  /// ✅ Fallback models (FREE ONLY)
  static const List<String> fallbackModels = [
    'gemini-1.5-flash', // Primary free model
    'gemini-1.0-pro',   // Legacy free fallback
  ];

  /// Temperature presets
  static const double creativeTemperature = 0.9;
  static const double balancedTemperature = 0.7;
  static const double preciseTemperature = 0.3;

  /// Token limits (FREE SAFE VALUES)
  static const int maxOutputTokens = 2048;
  static const int maxInputTokens = 32768;

  /// Safety settings
  static const String blockNone = 'BLOCK_NONE';
  static const String blockOnlyHigh = 'BLOCK_ONLY_HIGH';
  static const String blockMediumAndAbove = 'BLOCK_MEDIUM_AND_ABOVE';
}
