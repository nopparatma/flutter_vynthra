class PromptModel {
  String promptType;
  String prompt;
  String responseSample;

  PromptModel({
    required this.promptType,
    required this.prompt,
    required this.responseSample,
  });

  factory PromptModel.fromMap(Map<String, dynamic> map) {
    return PromptModel(
      promptType: map['promptType'] ?? '',
      prompt: map['prompt'] ?? '',
      responseSample: map['responseSample'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'promptType': promptType,
      'prompt': prompt,
      'responseSample': responseSample,
    };
  }
}
