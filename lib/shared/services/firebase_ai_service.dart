import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/gemini_constants.dart';
import '../../core/errors/exceptions.dart';

/// Firebase AI service using Gemini Developer API
/// This service uses Firebase's Gemini Developer API backend for AI operations
class FirebaseAIService {
  FirebaseAIService() : _logger = Logger() {
    // Ensure Firebase is initialized
    if (Firebase.apps.isEmpty) {
      throw ApiException(
        message:
            'Firebase is not initialized. Please initialize Firebase before using FirebaseAIService.',
        code: 'FIREBASE_NOT_INITIALIZED',
      );
    }

    // Initialize the default model
    _initializeModel(GeminiConstants.defaultModel);
  }

  GenerativeModel? _model;
  final Logger _logger;

  /// Initialize a GenerativeModel with the specified model name
  void _initializeModel(String modelName) {
    try {
      _model = FirebaseAI.googleAI().generativeModel(
        model: modelName,
        generationConfig: GenerationConfig(
          temperature: GeminiConstants.balancedTemperature,
          maxOutputTokens: GeminiConstants.maxOutputTokens,
        ),
      );
    } catch (e) {
      _logger.e('Failed to initialize Firebase AI model', error: e);
      throw ApiException(
        message: 'Failed to initialize AI model: ${e.toString()}',
        code: 'MODEL_INIT_FAILED',
      );
    }
  }

  /// Get or create a model instance
  GenerativeModel _getModel({
    String? modelName,
    double? temperature,
    int? maxOutputTokens,
  }) {
    // If custom parameters are provided, create a new model instance
    if (temperature != null || maxOutputTokens != null || modelName != null) {
      final effectiveModelName = modelName ?? GeminiConstants.defaultModel;
      return FirebaseAI.googleAI().generativeModel(
        model: effectiveModelName,
        generationConfig: GenerationConfig(
          temperature: temperature ?? GeminiConstants.balancedTemperature,
          maxOutputTokens: maxOutputTokens ?? GeminiConstants.maxOutputTokens,
        ),
      );
    }

    // Use default model
    if (_model == null) {
      _initializeModel(GeminiConstants.defaultModel);
    }
    return _model!;
  }

  /// Generate text content using Firebase Gemini Developer API
  Future<String> generateText({
    required String prompt,
    String? systemInstruction,
    double? temperature,
    int? maxOutputTokens,
    int retryCount = 0,
    String? modelName,
  }) async {
    try {
      final model = _getModel(
        modelName: modelName,
        temperature: temperature,
        maxOutputTokens: maxOutputTokens,
      );

      // Build the prompt with optional system instruction
      final fullPrompt =
          systemInstruction != null ? '$systemInstruction\n\n$prompt' : prompt;
      final content = [Content.text(fullPrompt)];

      // Generate content
      final response = await model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw ApiException(
          message: 'Empty response from AI',
          code: 'EMPTY_RESPONSE',
        );
      }

      return response.text!;
    } catch (e) {
      _logger.e('Firebase AI error', error: e);

      // If model not found, try fallback models (only on first attempt, not retries)
      final errorMessage = e.toString().toLowerCase();
      if ((errorMessage.contains('not found') ||
              errorMessage.contains('not supported')) &&
          retryCount == 0) {
        final currentModelName = modelName ?? GeminiConstants.defaultModel;
        final currentModelIndex = GeminiConstants.fallbackModels.indexOf(
          currentModelName,
        );

        // Try next fallback model if available
        if (currentModelIndex >= 0 &&
            currentModelIndex < GeminiConstants.fallbackModels.length - 1) {
          final nextModel =
              GeminiConstants.fallbackModels[currentModelIndex + 1];
          _logger.w(
            'Model "$currentModelName" not available, trying fallback model: $nextModel',
          );
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
          _logger.w(
            'Model "$currentModelName" not in fallback list or not available, trying: $firstFallback',
          );
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
          _logger.e(
            'All available models exhausted. Tried: ${GeminiConstants.fallbackModels.join(", ")}',
          );
        }
      }

      // Retry logic for other errors
      if (retryCount < AppConstants.maxRetries) {
        _logger.i(
          'Retrying Firebase AI call (attempt ${retryCount + 1})',
        );
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
        message:
            'Failed to generate text: ${e.toString()}. Available models: ${GeminiConstants.fallbackModels.join(", ")}',
        code: 'GENERATION_FAILED',
      );
    }
  }

  /// Generate content with chat history using Firebase Gemini Developer API
  Future<String> generateChatResponse({
    required List<Content> chatHistory,
    required String userMessage,
    double? temperature,
    String? modelName,
    int retryCount = 0,
  }) async {
    try {
      final model = _getModel(
        modelName: modelName,
        temperature: temperature,
      );

      // Start a chat with history
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
      _logger.e('Firebase AI chat error', error: e);

      // If model not found, try fallback models
      final errorMessage = e.toString().toLowerCase();
      if ((errorMessage.contains('not found') ||
              errorMessage.contains('not supported')) &&
          retryCount == 0) {
        final currentModelName = modelName ?? GeminiConstants.defaultModel;
        final currentModelIndex = GeminiConstants.fallbackModels.indexOf(
          currentModelName,
        );

        if (currentModelIndex >= 0 &&
            currentModelIndex < GeminiConstants.fallbackModels.length - 1) {
          final nextModel =
              GeminiConstants.fallbackModels[currentModelIndex + 1];
          _logger.w(
            'Model "$currentModelName" not available for chat, trying fallback: $nextModel',
          );
          return generateChatResponse(
            chatHistory: chatHistory,
            userMessage: userMessage,
            temperature: temperature,
            modelName: nextModel,
            retryCount: 0,
          );
        } else if (currentModelIndex < 0) {
          final firstFallback = GeminiConstants.fallbackModels.first;
          _logger.w(
            'Model "$currentModelName" not in fallback list, trying: $firstFallback',
          );
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
        message:
            'Failed to generate chat response: ${e.toString()}. Available models: ${GeminiConstants.fallbackModels.join(", ")}',
        code: 'CHAT_FAILED',
      );
    }
  }

  /// Generate structured JSON response using Firebase Gemini Developer API
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

  /// Check if Firebase AI is properly configured
  Future<bool> validateConfiguration() async {
    try {
      await generateText(prompt: 'test');
      return true;
    } catch (e) {
      return false;
    }
  }
}
