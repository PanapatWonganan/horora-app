class CompatibilityResult {
  final String sign1;
  final String sign2;
  final int overallScore;
  final int loveScore;
  final int workScore;
  final String description;
  final String loveCompatibility;
  final String workCompatibility;
  final String advice;

  CompatibilityResult({
    required this.sign1,
    required this.sign2,
    required this.overallScore,
    required this.loveScore,
    required this.workScore,
    required this.description,
    required this.loveCompatibility,
    required this.workCompatibility,
    required this.advice,
  });

  factory CompatibilityResult.fromJson(Map<String, dynamic> json) {
    return CompatibilityResult(
      sign1: json['sign1'] ?? '',
      sign2: json['sign2'] ?? '',
      overallScore: json['overall_score'] ?? 0,
      loveScore: json['love_score'] ?? 0,
      workScore: json['work_score'] ?? 0,
      description: json['description'] ?? '',
      loveCompatibility: json['love_compatibility'] ?? '',
      workCompatibility: json['work_compatibility'] ?? '',
      advice: json['advice'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sign1': sign1,
      'sign2': sign2,
      'overall_score': overallScore,
      'love_score': loveScore,
      'work_score': workScore,
      'description': description,
      'love_compatibility': loveCompatibility,
      'work_compatibility': workCompatibility,
      'advice': advice,
    };
  }
}
