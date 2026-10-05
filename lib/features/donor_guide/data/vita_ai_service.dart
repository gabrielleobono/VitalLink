import 'dart:convert';

import 'package:http/http.dart' as http;

/// Donne à Vita des réactions générées par IA (même backend Rodium que
/// `scan_ai`, modèle Gemini 2.5 Flash) pendant le quiz d'éligibilité.
///
/// Ne porte jamais la logique métier : les questions, les seuils et le
/// disclaimer restent fixes et déterministes ailleurs. Retourne toujours
/// `null` en cas d'absence de clé, de réseau indisponible ou d'échec de
/// requête — l'appelant bascule alors sur une phrase locale de repli.
class VitaAiService {
  VitaAiService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey =
          apiKey ??
          const String.fromEnvironment('RODIUM_API_KEY', defaultValue: '');

  final http.Client _client;
  final String _apiKey;

  static const _endpoint = 'https://api.rodiumai.io/v1/chat/completions';
  static const _systemPrompt =
      "Tu es Vita, l'assistante conviviale de l'app VitalLink qui guide un "
      "quiz d'éligibilité au don de sang. Réagis en une phrase courte (12 "
      "mots maximum), chaleureuse, en français, sans jamais donner de "
      "conseil médical ni reformuler les règles d'éligibilité. Réponds "
      "uniquement par la phrase, sans guillemets.";

  Future<String?> _complete(String userPrompt) async {
    if (_apiKey.isEmpty) return null;
    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': 'google/gemini-2.5-flash',
              'messages': [
                {'role': 'system', 'content': _systemPrompt},
                {'role': 'user', 'content': userPrompt},
              ],
              'temperature': 0.7,
              'max_tokens': 120,
            }),
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final choice = data['choices']?[0];
      // Coupé par la limite de tokens avant la fin de la phrase : on
      // préfère la phrase de repli locale plutôt qu'un texte tronqué.
      if (choice?['finish_reason'] == 'length') return null;
      final content = choice?['message']?['content'] as String?;
      final text = content?.trim().replaceAll('"', '');
      return (text == null || text.isEmpty) ? null : text;
    } catch (_) {
      return null;
    }
  }

  Future<String?> greeting() => _complete(
    "Salue chaleureusement la personne et annonce que tu vas lui poser "
    "quelques questions pour savoir si elle peut donner son sang "
    "aujourd'hui.",
  );

  Future<String?> ackFor({required String question, required String answer}) =>
      _complete(
        'La personne a répondu "$answer" à la question "$question". '
        'Réagis brièvement avant de passer à la suite.',
      );
}
