import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/generation_constants.dart';
import '../constants/deepseek_prompts.dart';
import '../models/translation_request.dart';

class _CacheEntry {
  final String value;
  final DateTime expiry;
  _CacheEntry(this.value, this.expiry);
  bool get isExpired => DateTime.now().isAfter(expiry);
}

class DeepSeekApiService {
  final String apiKey;
  final String customPrompt;
  final int timeout;
  final String model;
  final String promptPreset;
  final int maxTokensRegular;
  final int maxTokensJson;

  final Map<String, _CacheEntry> _cache = {};
  final bool enableCache;

  DeepSeekApiService({
    required this.apiKey,
    this.customPrompt = '',
    this.timeout = 180,
    this.model = 'deepseek-chat',
    this.promptPreset = 'balanced',
    this.maxTokensRegular = 500,
    this.maxTokensJson = 8000,
    this.enableCache = true,
  });

  static const int _maxCacheSize = 200;

  void _cleanExpiredCache() {
    _cache.removeWhere((key, entry) => entry.isExpired);
    if (_cache.length > _maxCacheSize) {
      final keysToRemove = _cache.keys.take(_cache.length - _maxCacheSize ~/ 2);
      for (final key in keysToRemove) {
        _cache.remove(key);
      }
    }
  }

  Future<String?> translateLine({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? type,
    String? context,
    Function(double)? onProgress,
  }) async {
    if (text.trim().isEmpty) {
      return null;
    }

    final cacheKey = '$sourceLanguage:$targetLanguage:${type ?? 'default'}:$text';
    if (enableCache) {
      _cleanExpiredCache();
      final cached = _cache[cacheKey];
      if (cached != null && !cached.isExpired) {
        debugPrint('✓ Using cached translation: ${text.length > 30 ? '${text.substring(0, 30)}...' : text}');
        return cached.value;
      }
    }

    final prompt = GenerationConstants.getPromptForTranslation(
      sourceLanguage,
      targetLanguage,
      type: type,
    ).replaceFirst('{text}', text);

    final startTime = DateTime.now();

    for (int attempt = 0; attempt < GenerationConstants.maxRetries; attempt++) {
      try {
        final response = await _makeRequest(prompt, targetLanguage);

        if (response != null) {
          debugPrint('✓ Translated successfully (attempt ${attempt + 1}): ${text.length > 30 ? '${text.substring(0, 30)}...' : text}');

          if (enableCache) {
            _cache[cacheKey] = _CacheEntry(response, DateTime.now().add(Duration(hours: 24)));
          }

          return response;
        }
      } catch (e) {
        debugPrint('✗ Translation attempt ${attempt + 1} failed: $e');

        if (attempt == GenerationConstants.maxRetries - 1) {
          debugPrint('✗ All retries failed for: ${text.length > 30 ? '${text.substring(0, 30)}...' : text}');
          rethrow;
        }

        await Future.delayed(Duration(milliseconds: 1000 * (attempt + 1)));
      }
    }

    return null;
  }

  Future<List<String>> translateBatch({
    required List<String> texts,
    required String sourceLanguage,
    required String targetLanguage,
    String? type,
    Function(int current, int total)? onProgress,
  }) async {
    final translations = <String>[];
    final futures = <Future<String?>>[];
    final semaphore = _Semaphore(GenerationConstants.maxConcurrentRequests);

    for (int i = 0; i < texts.length; i++) {
      futures.add(() async {
        await semaphore.acquire();
        try {
          final result = await translateLine(
            text: texts[i],
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            type: type,
          );
          onProgress?.call(i + 1, texts.length);
          return result;
        } finally {
          semaphore.release();
        }
      }());
    }

    final results = await Future.wait(futures, eagerError: false);

    for (final result in results) {
      translations.add(result ?? '');
    }

    return translations;
  }

  Future<bool> validateApiKey() async {
    try {
      final response = await _makeRequest('Hello', 'English');
      return response != null;
    } catch (e) {
      debugPrint('API key validation failed: $e');
      return false;
    }
  }

  Future<String?> _makeRequest(String prompt, String targetLanguage, {int? maxTokens, bool requireJson = false}) async {
    final effectiveMaxTokens = maxTokens ?? maxTokensRegular;
    final url = Uri.parse('${GenerationConstants.deepseekBaseUrl}/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final bodyMap = {
      'model': model.isNotEmpty ? model : GenerationConstants.deepseekModel,
      'messages': [
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      'temperature': 0.7,
      'max_tokens': effectiveMaxTokens,
    };

    if (requireJson && (model.contains('chat') || model.contains('coder'))) {
      bodyMap['response_format'] = {'type': 'json_object'};
    }

    final body = json.encode(bodyMap);

    debugPrint('=== API Request ===');
    debugPrint('Model: ${model.isNotEmpty ? model : GenerationConstants.deepseekModel}');
    debugPrint('Max tokens: $maxTokens');
    debugPrint('Require JSON: $requireJson');
    debugPrint('Prompt length: ${prompt.length} characters');

    final response = await http
        .post(url, headers: headers, body: body)
        .timeout(Duration(seconds: timeout));

    debugPrint('=== API Response ===');
    debugPrint('Status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>?;
          if (message != null) {
            final content = message['content'] as String?;
            if (content != null) {
              debugPrint('✓ Response received: ${content.length} characters');
              return content.trim();
            }
          }
        }
        debugPrint('✗ Invalid response structure');
        debugPrint('Response: ${response.body}');
      } catch (e) {
        debugPrint('✗ Error parsing response: $e');
        debugPrint('Response body: ${response.body}');
      }
    } else {
      debugPrint('✗ API request failed');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
    }

    return null;
  }

  Future<Map<String, dynamic>> generateAllTranslations({
    required String text,
    required List<String> languages,
    required String sourceLanguage,
    required String transcriptionLanguage,
    Function(double)? onProgress,
  }) async {
    if (text.trim().isEmpty) {
      return {};
    }

    String prompt;
    if (customPrompt.isNotEmpty) {
      final languagesStr = languages.join(', ');
      prompt = customPrompt.replaceAll('{text}', text)
                         .replaceAll('{sourceLanguage}', sourceLanguage)
                         .replaceAll('{transcriptionLanguage}', transcriptionLanguage)
                         .replaceAll('{languages}', languagesStr);
    } else {
      prompt = DeepSeekPrompts.getPromptForPreset(
        promptPreset,
        text,
        languages,
        sourceLanguage,
        transcriptionLanguage,
      );
    }

    debugPrint('=== Generating all translations ===');
    debugPrint('Languages: ${languages.join(", ")}');
    debugPrint('Source language: $sourceLanguage');
    debugPrint('Transcription language: $transcriptionLanguage');
    debugPrint('Text length: ${text.length} characters');

    onProgress?.call(0.1);

    try {
      final response = await _makeRequest(prompt, 'all', maxTokens: maxTokensJson, requireJson: true);

      if (response != null) {
        debugPrint('✓ Translations generated successfully');

        String cleanedResponse = response;

        if (cleanedResponse.startsWith('```json')) {
          cleanedResponse = cleanedResponse.substring(7);
        } else if (cleanedResponse.startsWith('```')) {
          cleanedResponse = cleanedResponse.substring(3);
        }

        if (cleanedResponse.endsWith('```')) {
          cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
        }

        cleanedResponse = cleanedResponse.trim();

        try {
          final data = json.decode(cleanedResponse) as Map<String, dynamic>;
          debugPrint('✓ Parsed JSON response successfully');
          onProgress?.call(1.0);
          return data;
        } catch (jsonError) {
          debugPrint('✗ JSON parse error: $jsonError');
          debugPrint('Attempting to extract JSON from response...');
          final jsonStart = cleanedResponse.indexOf('{');
          final jsonEnd = cleanedResponse.lastIndexOf('}');
          if (jsonStart >= 0 && jsonEnd > jsonStart) {
            final extractedJson = cleanedResponse.substring(jsonStart, jsonEnd + 1);
            try {
              final data = json.decode(extractedJson) as Map<String, dynamic>;
              debugPrint('✓ Extracted and parsed JSON from response');
              onProgress?.call(1.0);
              return data;
            } catch (e) {
              debugPrint('✗ Failed to parse extracted JSON: $e');
            }
          }
          debugPrint('Response content preview: ${cleanedResponse.length > 500 ? '${cleanedResponse.substring(0, 500)}...' : cleanedResponse}');
          return {};
        }
      } else {
        debugPrint('✗ No response from API');
        return {};
      }
    } catch (e) {
      debugPrint('✗ Error generating translations: $e');
      return {};
    }
  }
}

class _Semaphore {
  final int maxCount;
  int _currentCount = 0;
  final _waiters = <void Function()>[];

  _Semaphore(this.maxCount);

  Future<void> acquire() async {
    while (true) {
      if (_currentCount < maxCount) {
        _currentCount++;
        return;
      }

      final completer = Completer<void>();
      _waiters.add(() => completer.complete());
      await completer.future;
    }
  }

  void release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeAt(0)();
    } else {
      _currentCount--;
    }
  }
}
