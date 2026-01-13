import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/gemini_constants.dart';
import '../../core/config/gemini_config.dart';
import '../../core/errors/exceptions.dart';

/// Centralized Gemini AI service
class GeminiService {
  GeminiService({String? apiKey})
      : _apiKey = apiKey ?? GeminiConfig.getApiKey(),
        _logger = Logger() {
    final apiKeyValue = _apiKey;
    if (apiKeyValue == null || apiKeyValue.isEmpty) {
      try {
        GeminiConfig.validateApiKey();
      } catch (e) {
        throw ApiException(
          message: e.toString(),
          code: 'MISSING_API_KEY',
        );
      }
      // Should not reach here, but just in case
      throw ApiException(
        message: 'Gemini API key is not configured. Please check configuration.',
        code: 'MISSING_API_KEY',
      );
    }

    // Initialize with default model
    // Note: Model validation happens when generateContent is called, not in constructor
    _model = GenerativeModel(
      model: GeminiConstants.defaultModel,
      apiKey: apiKeyValue,
      generationConfig: GenerationConfig(
        temperature: GeminiConstants.balancedTemperature,
        maxOutputTokens: GeminiConstants.maxOutputTokens,
      ),
    );
  }

  final String? _apiKey;
  late final GenerativeModel _model;
  final Logger _logger;

  /// Generate text content
  Future<String> generateText({
    required String prompt,
    String? systemInstruction,
    double? temperature,
    int? maxOutputTokens,
    int retryCount = 0,
    String? modelName,
  }) async {
    try {
      final effectiveModelName = modelName ?? GeminiConstants.defaultModel;
      final model = temperature != null || maxOutputTokens != null || modelName != null
          ? GenerativeModel(
              model: effectiveModelName,
              apiKey: _apiKey!,
              generationConfig: GenerationConfig(
                temperature: temperature ?? GeminiConstants.balancedTemperature,
                maxOutputTokens: maxOutputTokens ?? GeminiConstants.maxOutputTokens,
              ),
            )
          : _model;

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw ApiException(
          message: 'Empty response from AI',
          code: 'EMPTY_RESPONSE',
        );
      }

      return response.text!;
    } catch (e) {
      _logger.e('Gemini API error', error: e);

      // If model not found, try fallback models (only on first attempt, not retries)
      final errorMessage = e.toString().toLowerCase();
      if ((errorMessage.contains('not found') || errorMessage.contains('not supported')) && retryCount == 0) {
        final currentModelName = modelName ?? GeminiConstants.defaultModel;
        final currentModelIndex = GeminiConstants.fallbackModels.indexOf(currentModelName);
        
        // Try next fallback model if available
        if (currentModelIndex >= 0 && currentModelIndex < GeminiConstants.fallbackModels.length - 1) {
          final nextModel = GeminiConstants.fallbackModels[currentModelIndex + 1];
          _logger.w('Model "$currentModelName" not available, trying fallback model: $nextModel');
          return generateText(
            prompt: prompt,
            systemInstruction: systemInstruction,
            temperature: temperature,
            maxOutputTokens: maxOutputTokens,
            retryCount: 0,
            modelName: nextModel,
          );
        } else if (currentModelIndex < 0) {
          // If current model not in fallback list, try first available model
          final firstFallback = GeminiConstants.fallbackModels.first;
          _logger.w('Model "$currentModelName" not in fallback list or not available, trying: $firstFallback');
          return generateText(
            prompt: prompt,
            systemInstruction: systemInstruction,
            temperature: temperature,
            maxOutputTokens: maxOutputTokens,
            retryCount: 0,
            modelName: firstFallback,
          );
        } else {
          // We've tried all fallback models, log and throw
          _logger.e('All available models exhausted. Tried: ${GeminiConstants.fallbackModels.join(", ")}');
        }
      }

      // Retry logic for other errors
      if (retryCount < AppConstants.maxRetries) {
        _logger.i('Retrying Gemini API call (attempt ${retryCount + 1})');
        await Future.delayed(AppConstants.retryDelay);
        return generateText(
          prompt: prompt,
          systemInstruction: systemInstruction,
          temperature: temperature,
          maxOutputTokens: maxOutputTokens,
          retryCount: retryCount + 1,
          modelName: modelName,
        );
      }

      if (e is ApiException) rethrow;

      throw ApiException(
        message: 'Failed to generate text: ${e.toString()}. Available models: ${GeminiConstants.fallbackModels.join(", ")}',
        code: 'GENERATION_FAILED',
      );
    }
  }

  /// Generate content with chat history
  Future<String> generateChatResponse({
    required List<Content> chatHistory,
    required String userMessage,
    double? temperature,
    String? modelName,
    int retryCount = 0,
  }) async {
    try {
      final effectiveModelName = modelName ?? GeminiConstants.defaultModel;
      final model = temperature != null || modelName != null
          ? GenerativeModel(
              model: effectiveModelName,
              apiKey: _apiKey!,
              generationConfig: GenerationConfig(
                temperature: temperature ?? GeminiConstants.balancedTemperature,
                maxOutputTokens: GeminiConstants.maxOutputTokens,
              ),
            )
          : _model;

      final chat = model.startChat(history: chatHistory);
      final response = await chat.sendMessage(Content.text(userMessage));

      if (response.text == null || response.text!.isEmpty) {
        throw ApiException(
          message: 'Empty response from AI',
          code: 'EMPTY_RESPONSE',
        );
      }

      return response.text!;
    } catch (e) {
      _logger.e('Gemini chat error', error: e);

      // If model not found, try fallback models
      final errorMessage = e.toString().toLowerCase();
      if ((errorMessage.contains('not found') || errorMessage.contains('not supported')) && retryCount == 0) {
        final currentModelName = modelName ?? GeminiConstants.defaultModel;
        final currentModelIndex = GeminiConstants.fallbackModels.indexOf(currentModelName);
        
        if (currentModelIndex >= 0 && currentModelIndex < GeminiConstants.fallbackModels.length - 1) {
          final nextModel = GeminiConstants.fallbackModels[currentModelIndex + 1];
          _logger.w('Model "$currentModelName" not available for chat, trying fallback: $nextModel');
          return generateChatResponse(
            chatHistory: chatHistory,
            userMessage: userMessage,
            temperature: temperature,
            modelName: nextModel,
            retryCount: 0,
          );
        } else if (currentModelIndex < 0) {
          final firstFallback = GeminiConstants.fallbackModels.first;
          _logger.w('Model "$currentModelName" not in fallback list, trying: $firstFallback');
          return generateChatResponse(
            chatHistory: chatHistory,
            userMessage: userMessage,
            temperature: temperature,
            modelName: firstFallback,
            retryCount: 0,
          );
        }
      }

      if (e is ApiException) rethrow;

      throw ApiException(
        message: 'Failed to generate chat response: ${e.toString()}. Available models: ${GeminiConstants.fallbackModels.join(", ")}',
        code: 'CHAT_FAILED',
      );
    }
  }

  /// Generate structured JSON response
  Future<Map<String, dynamic>> generateStructuredResponse({
    required String prompt,
    required String jsonSchema,
    double? temperature,
  }) async {
    try {
      final structuredPrompt = '''
$prompt

Please respond ONLY with valid JSON matching this schema:
$jsonSchema

Do not include any markdown formatting or explanations. Only return the JSON object.
''';

      final response = await generateText(
        prompt: structuredPrompt,
        temperature: temperature ?? GeminiConstants.preciseTemperature,
      );

      // Clean response (remove markdown code blocks if present)
      var cleanResponse = response.trim();
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.startsWith('```')) {
        cleanResponse = cleanResponse.substring(3);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      cleanResponse = cleanResponse.trim();

      // Parse JSON
      final jsonData = json.decode(cleanResponse) as Map<String, dynamic>;
      return jsonData;
    } catch (e) {
      _logger.e('Failed to parse structured response', error: e);
      throw ApiException(
        message: 'Failed to generate structured response: ${e.toString()}',
        code: 'STRUCTURED_RESPONSE_FAILED',
      );
    }
  }

  /// Check if API key is valid
  Future<bool> validateApiKey() async {
    try {
      await generateText(prompt: 'test');
      return true;
    } catch (e) {
      return false;
    }
  }
}

