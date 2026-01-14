class InterviewQuestion {
  final String question;
  final List<String> options; // Should always have 4 options
  final int correctAnswerIndex; // 0-3
  final String? explanation;

  InterviewQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
  }) : assert(options.length == 4, 'Interview question must have exactly 4 options');

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }

  factory InterviewQuestion.fromJson(Map<String, dynamic> json) {
    return InterviewQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanation: json['explanation'] as String?,
    );
  }
}