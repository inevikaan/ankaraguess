class Question {
  final String title;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.title,
    required this.options,
    required this.correctIndex,
  });
}