import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/donor_eligibility_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../data/vita_ai_service.dart';

enum _QuestionType { number, yesNo }

final _random = Random();

const _genericAcks = [
  'Merci, c\'est noté.',
  'D\'accord, bien reçu.',
  'Compris, on continue.',
  'Ok, merci pour cette précision.',
];

class _Question {
  const _Question({
    required this.prompt,
    required this.type,
    required this.isDisqualifying,
    required this.failureReason,
    this.unit,
    this.minValid,
    this.maxValid,
    this.trueLabel = 'Oui',
    this.falseLabel = 'Non',
    this.neutralChoice = false,
    this.answerLabel,
    this.ackPool,
    this.skip,
  });

  final String prompt;
  final _QuestionType type;

  /// `true` si la réponse donnée écarte le don.
  final bool Function(num answer) isDisqualifying;
  final String failureReason;

  /// Suffixe affiché dans la bulle de réponse ("ans", "kg").
  final String? unit;

  /// Bornes de saisie raisonnables, pour les questions numériques.
  final int? minValid;
  final int? maxValid;

  /// Libellés des boutons pour une question "yesNo" (par défaut Oui/Non ;
  /// utilisé par ex. pour Homme/Femme).
  final String trueLabel;
  final String falseLabel;

  /// `true` pour un choix neutre (ex: sexe) plutôt que Non/Oui coloré
  /// comme un critère d'exclusion.
  final bool neutralChoice;

  /// Texte affiché dans la bulle de réponse de l'utilisateur ; par défaut
  /// trueLabel/falseLabel pour yesNo, "valeur unité" pour number.
  final String Function(num answer)? answerLabel;

  /// Variantes de phrase d'accusé de réception affichées après la réponse,
  /// piochées au hasard pour rendre la conversation moins mécanique.
  final List<String> Function(num answer)? ackPool;

  /// `true` si cette question doit être sautée, en fonction des réponses
  /// déjà données (ex: grossesse sautée si "Homme" a été répondu).
  final bool Function(List<num?> answers)? skip;
}

final _questions = [
  _Question(
    prompt: 'Pour commencer, quel est ton âge ?',
    type: _QuestionType.number,
    unit: 'ans',
    minValid: 0,
    maxValid: 120,
    isDisqualifying: (age) =>
        age < DonorEligibilityConstants.minAge ||
        age > DonorEligibilityConstants.maxAge,
    failureReason:
        'L\'âge doit être compris entre ${DonorEligibilityConstants.minAge} '
        'et ${DonorEligibilityConstants.maxAge} ans.',
    ackPool: (age) => [
      'D\'accord, $age ans, merci !',
      '$age ans, bien noté.',
      'Merci, $age ans, ça me va.',
    ],
  ),
  _Question(
    prompt: 'Et quel est ton poids, en kg ?',
    type: _QuestionType.number,
    unit: 'kg',
    minValid: 0,
    maxValid: 300,
    isDisqualifying: (weight) =>
        weight < DonorEligibilityConstants.minWeightKg,
    failureReason:
        'Le poids minimal requis est de '
        '${DonorEligibilityConstants.minWeightKg} kg.',
    ackPool: (weight) => [
      'Merci, $weight kg, c\'est noté.',
      'D\'accord, $weight kg.',
      '$weight kg, bien reçu, merci.',
    ],
  ),
  _Question(
    prompt: 'Es-tu un homme ou une femme ?',
    type: _QuestionType.yesNo,
    trueLabel: 'Femme',
    falseLabel: 'Homme',
    neutralChoice: true,
    answerLabel: (v) => v == 1 ? 'Femme' : 'Homme',
    isDisqualifying: (_) => false,
    failureReason: '',
    ackPool: (_) => const ['Merci !', 'D\'accord, merci.', 'Ok, noté.'],
  ),
  _Question(
    prompt:
        'As-tu été malade (fièvre, infection) au cours des '
        '${DonorEligibilityConstants.minDaysSinceIllness} derniers jours ?',
    type: _QuestionType.yesNo,
    isDisqualifying: (v) => v == 1,
    failureReason:
        'Il faut attendre la fin complète du rétablissement (environ '
        '${DonorEligibilityConstants.minDaysSinceIllness} jours).',
  ),
  _Question(
    prompt:
        'As-tu fait un tatouage ou un piercing au cours des '
        '${DonorEligibilityConstants.minDaysSinceTattoo} derniers jours ?',
    type: _QuestionType.yesNo,
    isDisqualifying: (v) => v == 1,
    failureReason:
        'Un délai d\'environ ${DonorEligibilityConstants.minDaysSinceTattoo} '
        'jours est requis après un tatouage ou un piercing.',
  ),
  _Question(
    prompt:
        'Es-tu enceinte, ou as-tu accouché au cours des '
        '${DonorEligibilityConstants.minMonthsSincePregnancy} derniers '
        'mois ?',
    type: _QuestionType.yesNo,
    isDisqualifying: (v) => v == 1,
    failureReason:
        'Un délai de ${DonorEligibilityConstants.minMonthsSincePregnancy} '
        'mois après un accouchement est requis.',
    // Index 2 = la question "homme ou femme" posée juste avant.
    skip: (answers) => answers[2] == 0,
  ),
  _Question(
    prompt:
        'Dernière question : as-tu donné du sang au cours des '
        '${DonorEligibilityConstants.minDaysSinceLastDonation} derniers '
        'jours ?',
    type: _QuestionType.yesNo,
    isDisqualifying: (v) => v == 1,
    failureReason:
        'Le délai minimal entre deux dons est de '
        '${DonorEligibilityConstants.minDaysSinceLastDonation} jours.',
  ),
];

const _greetingFallback =
    'Salut ! Moi c\'est Vita 👋 Je vais te poser quelques petites questions '
    'pour voir si tu peux donner ton sang aujourd\'hui.';

const _disclaimer =
    'Ce guide est indicatif. La décision finale revient au personnel '
    'médical.';

class _ChatLine {
  const _ChatLine({required this.fromVita, required this.text});
  final bool fromVita;
  final String text;
}

/// Quiz d'éligibilité mis en scène comme une conversation avec l'assistante
/// "Vita" (façon messagerie) — mais la logique reste un simple arbre de
/// règles Dart, sans aucun appel IA ni réseau (fonctionne hors-ligne).
class EligibilityQuiz extends StatefulWidget {
  const EligibilityQuiz({super.key});

  @override
  State<EligibilityQuiz> createState() => _EligibilityQuizState();
}

class _EligibilityQuizState extends State<EligibilityQuiz> {
  final List<num?> _answers = List.filled(_questions.length, null);
  int _step = 0;
  String? _inputError;

  final _numberController = TextEditingController();
  final _scrollController = ScrollController();
  final _vitaAi = VitaAiService();

  final List<_ChatLine> _visibleLines = [];
  bool _vitaTyping = false;

  bool get _isDone => _step >= _questions.length;

  /// Avance `_step` au-delà de toute question à sauter (ex: grossesse pour
  /// un homme), sans jamais les poser.
  void _skipIneligibleQuestions() {
    while (_step < _questions.length &&
        (_questions[_step].skip?.call(_answers) ?? false)) {
      _step++;
    }
  }

  @override
  void initState() {
    super.initState();
    _runIntro();
  }

  @override
  void dispose() {
    _numberController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _formatAnswer(_Question question, num answer) {
    return question.answerLabel?.call(answer) ??
        (question.type == _QuestionType.number
            ? '${answer.toInt()} ${question.unit ?? ''}'.trim()
            : (answer == 1 ? question.trueLabel : question.falseLabel));
  }

  String _fallbackAckFor(_Question question, num answer) {
    final pool = question.ackPool?.call(answer) ?? _genericAcks;
    return pool[_random.nextInt(pool.length)];
  }

  /// Affiche le "typing…", attend au moins un temps minimal (pour garder
  /// l'effet de frappe même si l'IA répond vite), tente l'appel [aiCall],
  /// et retombe sur [fallback] si l'IA ne répond pas (pas de clé, pas de
  /// réseau, timeout, erreur).
  Future<String> _withTyping(Future<String?> aiCall, String fallback) async {
    setState(() => _vitaTyping = true);
    _scrollToBottom();
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return fallback;
    final aiText = await aiCall;
    if (!mounted) return fallback;
    return aiText ?? fallback;
  }

  Future<void> _revealVitaLine(String text) async {
    if (!mounted) return;
    setState(() {
      _vitaTyping = false;
      _visibleLines.add(_ChatLine(fromVita: true, text: text));
    });
    _scrollToBottom();
  }

  Future<void> _revealFixed(String text) async {
    setState(() => _vitaTyping = true);
    _scrollToBottom();
    await Future.delayed(const Duration(milliseconds: 900));
    await _revealVitaLine(text);
  }

  Future<void> _runIntro() async {
    final text = await _withTyping(_vitaAi.greeting(), _greetingFallback);
    await _revealVitaLine(text);
    if (!mounted) return;
    await _revealFixed(_questions[0].prompt);
  }

  Future<void> _advance(_Question question, num value) async {
    final i = _step;
    _answers[i] = value;
    final echo = _formatAnswer(question, value);
    setState(() => _visibleLines.add(_ChatLine(fromVita: false, text: echo)));
    _scrollToBottom();

    final ack = await _withTyping(
      _vitaAi.ackFor(question: question.prompt, answer: echo),
      _fallbackAckFor(question, value),
    );
    await _revealVitaLine(ack);
    if (!mounted) return;

    setState(() {
      _step++;
      _skipIneligibleQuestions();
    });

    if (_isDone) {
      await _revealResult();
    } else {
      await _revealFixed(_questions[_step].prompt);
    }
  }

  Future<void> _revealResult() async {
    final reasons = [
      for (var i = 0; i < _questions.length; i++)
        if (_answers[i] != null && _questions[i].isDisqualifying(_answers[i]!))
          _questions[i].failureReason,
    ];
    final resultText = reasons.isEmpty
        ? 'Bonne nouvelle : rien ne semble t\'empêcher de donner ton sang '
              'aujourd\'hui !'
        : 'D\'après tes réponses, il vaut mieux attendre un peu avant de '
              'donner :\n${reasons.map((r) => '• $r').join('\n')}';
    await _revealFixed(resultText);
    if (!mounted) return;
    await _revealFixed(_disclaimer);
  }

  void _submitNumber() {
    final question = _questions[_step];
    final value = int.tryParse(_numberController.text.trim());
    if (value == null ||
        value < (question.minValid ?? 0) ||
        value > (question.maxValid ?? 999)) {
      setState(() => _inputError = 'Entre une valeur valide.');
      return;
    }
    setState(() => _inputError = null);
    _numberController.clear();
    _advance(question, value);
  }

  void _answerYesNo(bool yes) {
    final question = _questions[_step];
    _advance(question, yes ? 1 : 0);
  }

  void _restart() {
    setState(() {
      _step = 0;
      _answers.setAll(0, List.filled(_questions.length, null));
      _inputError = null;
      _numberController.clear();
      _visibleLines.clear();
    });
    _runIntro();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = _visibleLines.length + (_vitaTyping ? 1 : 0);
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index == _visibleLines.length) return const _TypingBubble();
              return _ChatBubble(line: _visibleLines[index]);
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _vitaTyping
                ? const SizedBox.shrink()
                : _isDone
                ? SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _restart,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Refaire le quiz'),
                    ),
                  )
                : _questions[_step].type == _QuestionType.number
                ? _NumberInputBar(
                    controller: _numberController,
                    unit: _questions[_step].unit,
                    error: _inputError,
                    onSubmit: _submitNumber,
                  )
                : _YesNoBar(
                    trueLabel: _questions[_step].trueLabel,
                    falseLabel: _questions[_step].falseLabel,
                    neutral: _questions[_step].neutralChoice,
                    onAnswer: _answerYesNo,
                  ),
          ),
        ),
      ],
    );
  }
}

/// Avatar de "Vita" dans la conversation — reprend l'icône VitalLink
/// utilisée partout dans l'app (splash, profil, dashboard).
class _VitaAvatar extends StatelessWidget {
  const _VitaAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.water_drop, color: Colors.white, size: 16),
    );
  }
}

/// Bulle "Vita est en train d'écrire…" avec trois points animés, façon
/// Messenger/WhatsApp.
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _VitaAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: palette.border),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final phase = (_controller.value - i * 0.2) % 1.0;
                    final scale = 0.6 + 0.4 * (1 - (phase - 0.5).abs() * 2).clamp(0, 1);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: palette.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.line});

  final _ChatLine line;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bubbleColor = line.fromVita ? palette.surface : AppColors.primary;
    final textColor = line.fromVita ? palette.textPrimary : Colors.white;

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(line.fromVita ? 4 : 16),
            bottomRight: Radius.circular(line.fromVita ? 16 : 4),
          ),
          border: line.fromVita ? Border.all(color: palette.border) : null,
        ),
        child: Text(
          line.text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: line.fromVita
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const _VitaAvatar(),
                const SizedBox(width: 8),
                bubble,
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [bubble],
            ),
    );
  }
}

class _YesNoBar extends StatelessWidget {
  const _YesNoBar({
    required this.onAnswer,
    this.trueLabel = 'Oui',
    this.falseLabel = 'Non',
    this.neutral = false,
  });

  final void Function(bool yes) onAnswer;
  final String trueLabel;
  final String falseLabel;
  final bool neutral;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => onAnswer(false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(falseLabel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: neutral
              ? OutlinedButton(
                  onPressed: () => onAnswer(true),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(trueLabel),
                )
              : ElevatedButton(
                  onPressed: () => onAnswer(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(trueLabel),
                ),
        ),
      ],
    );
  }
}

class _NumberInputBar extends StatelessWidget {
  const _NumberInputBar({
    required this.controller,
    required this.onSubmit,
    this.unit,
    this.error,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final String? unit;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Text(
              error!,
              style: const TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  hintText: unit != null ? 'Réponds en $unit' : 'Ta réponse',
                  filled: true,
                  fillColor: palette.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: palette.border),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: onSubmit,
              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
