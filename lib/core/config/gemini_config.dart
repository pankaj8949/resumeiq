import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized configuration for Gemini API
/// 
/// Configuration Priority:
/// 1. .env file: GEMINI_API_KEY (loaded via flutter_dotenv)
/// 2. Environment variable: GEMINI_API_KEY (system environment)
/// 3. Config file: lib/core/config/gemini_api_key.txt (for development only)
class GeminiConfig {
  GeminiConfig._();

  /// Get API key from various sources
  static String? getApiKey() {
    // 1. Try .env file first (via flutter_dotenv)
    try {
      final dotenvKey = dotenv.env['GEMINI_API_KEY'];
      if (dotenvKey != null && dotenvKey.isNotEmpty) {
        // Remove quotes if present
        final cleanedKey = dotenvKey.replaceAll('"', '').replaceAll("'", '').trim();
        if (cleanedKey.isNotEmpty) {
          return cleanedKey;
        }
      }
    } catch (e) {
      // dotenv not loaded, continue to other methods
    }

    // 2. Try system environment variable
    final envKey = Platform.environment['GEMINI_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }

    // 2. Try config file (for development)
    try {
      final configFile = File('lib/core/config/gemini_api_key.txt');
      if (configFile.existsSync()) {
        final key = configFile.readAsStringSync().trim();
        if (key.isNotEmpty && !key.startsWith('your-api-key')) {
          return key;
        }
      }
    } catch (e) {
      // Ignore file read errors
    }

    // 3. Return null - user must configure
    return null;
  }

  /// Validate that API key is configured
  static void validateApiKey() {
    final apiKey = getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        r'''
        Gemini API key is not configured. Please check configuration.
        ''',
      );
    }
  }
}

