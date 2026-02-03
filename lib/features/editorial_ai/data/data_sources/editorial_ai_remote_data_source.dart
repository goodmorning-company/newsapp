import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../../domain/entities/draft_input.dart';
import '../../domain/entities/improved_draft.dart';

class EditorialAiRemoteDataSource {
  final String apiKey;
  final HttpClient _client;
  final Uri _endpoint;

  EditorialAiRemoteDataSource({
    required this.apiKey,
    HttpClient? client,
    Uri? endpoint,
  }) : _client = client ?? HttpClient(),
       _endpoint =
           endpoint ?? Uri.parse('https://api.openai.com/v1/chat/completions');

  Future<ImprovedDraft> improveDraft(DraftInput input) async {
    try {
      if (apiKey.isEmpty) {
        throw StateError('Missing OpenAI API key');
      }

      log('EDITORIAL_AI → REMOTE → calling OpenAI API', name: 'editorial_ai');

      final request = await _client.postUrl(_endpoint);
      request.headers
        ..contentType = ContentType.json
        ..set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');

      final payload = _buildPrompt(input);
      request.add(utf8.encode(json.encode(payload)));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        log(
          'EDITORIAL_AI → REMOTE → OpenAI response received',
          name: 'editorial_ai',
        );

        final data = json.decode(body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;

        if (choices == null || choices.isEmpty) {
          throw StateError('Empty response from OpenAI');
        }

        final message = choices.first['message'] as Map<String, dynamic>?;
        final content = message?['content'] as String? ?? '';

        final parsed = json.decode(content) as Map<String, dynamic>;
        final title = (parsed['title'] as String? ?? '').trim();
        final improvedContent = (parsed['content'] as String? ?? '').trim();

        return ImprovedDraft(title: title, content: improvedContent);
      } else {
        throw HttpException(
          'OpenAI error ${response.statusCode}: $body',
          uri: _endpoint,
        );
      }
    } catch (e) {
      log('EDITORIAL_AI → REMOTE → ERROR: $e', name: 'editorial_ai');
      rethrow;
    }
  }

  Map<String, dynamic> _buildPrompt(DraftInput input) {
    return {
      'model': 'gpt-4o-mini',
      'temperature': 0.4,
      'response_format': {'type': 'json_object'},
      'messages': [
        {
          'role': 'system',
          'content': '''
          You are a professional editorial assistant.

          You must output a valid JSON object.
          The response MUST be valid JSON and nothing else.
          Output a JSON object with exactly two keys: "title" and "content".

          Rewrite the draft in a neutral, journalistic tone that is clear, confident, and authoritative.
          Preserve the original meaning and facts; do not add new information.
          Improve clarity, flow, and structure, remove redundancy, strengthen the opening and transitions,
          and follow editorial hierarchy (lead → body → supporting points).

          The title and content must respect existing length limits.
          Do not mention limits, AI, or add any metadata.

          The content must be valid Markdown suitable for the existing Flutter Markdown renderer.
          Use structure intentionally:
          - Use "##" section headings where natural
          - Use "###" only when it adds clarity
          - Use **bold** for key concepts
          - Use *italic* for nuance or terminology
          - Use > blockquotes only when they improve readability

          Avoid emojis, marketing tone, fluff, tables, HTML, summaries, or commentary.
          ''',
        },
        {
          'role': 'user',
          'content': json.encode({
            'title': input.title.trim(),
            'content': input.content.trim(),
          }),
        },
      ],
    };
  }
}
