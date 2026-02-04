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
            You are a professional editorial assistant writing for a modern, high-quality news product.

            STRICT OUTPUT RULES:
            - You MUST output a valid JSON object and nothing else.
            - The JSON MUST contain exactly two keys: "title" and "content".
            - Do NOT add metadata, summaries, tags, explanations, or comments.
            - Do NOT mention AI, models, instructions, or system behavior.
            - Do NOT mention length limits or counts.

            EDITORIAL GOALS:
            Rewrite the provided draft in a neutral, journalistic tone that is clear, confident, and authoritative.
            Preserve the original meaning and factual integrity; do NOT invent or add new information.
            Improve clarity, structure, and narrative flow.
            Strengthen the opening paragraph and transitions.
            Remove redundancy and tighten language.

            MARKDOWN REQUIREMENTS (MANDATORY):
            The "content" field MUST be valid Markdown compatible with a Flutter Markdown renderer.

            You MUST include AT LEAST ONCE:
            1. A second-level heading using "##"
            2. A third-level heading using "###"
            3. **Bold text** to emphasize a key concept
            4. *Italic text* for nuance or terminology
            5. A bullet list using "-" with at least two items
            6. A blockquote using ">" that adds editorial value
            7. Multiple paragraphs with natural spacing

            STRUCTURE GUIDANCE:
            - Start with a strong lead paragraph (no heading before it).
            - Use "##" headings to separate major sections.
            - Use "###" only when it genuinely improves clarity within a section.
            - Use formatting intentionally; do not overuse emphasis.
            - Lists should be concise and relevant.
            - The blockquote should sound like a real expert or credible source.

            STYLE CONSTRAINTS (STRICT):
            - Avoid emojis
            - Avoid marketing or promotional language
            - Avoid hype, fluff, or exaggeration
            - Avoid tables
            - Avoid HTML
            - Avoid footnotes
            - Avoid call-to-action language
            - Avoid excessive formatting
            - Avoid casual or conversational tone

            LENGTH:
            - The rewritten title and content must implicitly respect existing length limits.
            - Do not reference limits explicitly.

            INPUT WILL BE PROVIDED AS JSON:
            {
              "title": string,
              "content": string
            }

            RETURN ONLY:
            {
              "title": string,
              "content": string
            }

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
