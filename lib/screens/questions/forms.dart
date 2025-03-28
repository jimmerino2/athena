import 'package:flutter/material.dart';

enum QuestionType {
  textField,
  dropdown,
  multipleChoice,
  yesNo,
  multipleTextField,
}

class QuestionWidget extends StatefulWidget {
  final String question;
  final QuestionType type;
  final List<String>? options;
  final Function(dynamic) onAnswerSelected;
  final dynamic initialAnswer;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.type,
    this.options,
    required this.onAnswerSelected,
    this.initialAnswer,
  });

  @override
  State<QuestionWidget> createState() => QuestionWidgetState();
}

class QuestionWidgetState extends State<QuestionWidget> {
  dynamic selectedAnswer;
  late TextEditingController _textController;
  Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    selectedAnswer = widget.initialAnswer;
    _textController = TextEditingController(
      text: widget.initialAnswer?.toString() ?? "",
    );
    selectedAnswer = widget.initialAnswer ?? {};

    if (widget.options != null) {
      for (var option in widget.options!) {
        controllers[option] = TextEditingController(
          text:
              (selectedAnswer is Map && selectedAnswer.containsKey(option))
                  ? selectedAnswer[option]
                  : "",
        );
      }
    }

    @override
    void dispose() {
      _textController.dispose();
      for (var controller in controllers.values) {
        controller.dispose();
      }
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.question, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildQuestionInput(),
        ],
      ),
    );
  }

  Widget _buildQuestionInput() {
    switch (widget.type) {
      case QuestionType.textField:
        return TextField(
          controller: _textController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter your answer...',
          ),
          onChanged: (value) {
            setState(() {
              selectedAnswer = value;
            });
            widget.onAnswerSelected(value);
          },
        );

      case QuestionType.dropdown:
        return DropdownButtonFormField<String>(
          value: selectedAnswer,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items:
              widget.options!.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
          onChanged: (String? value) {
            setState(() {
              selectedAnswer = value;
            });
            widget.onAnswerSelected(value);
          },
        );

      case QuestionType.multipleChoice:
        if (selectedAnswer is! Set<String>) {
          selectedAnswer = <String>{};
        }
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: widget.options?.length ?? 0,
                itemBuilder: (context, index) {
                  final option = widget.options![index];
                  final isSelected = selectedAnswer.contains(option);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedAnswer.remove(option);
                        } else {
                          selectedAnswer.add(option);
                        }
                      });
                      widget.onAnswerSelected(selectedAnswer);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );

      case QuestionType.multipleTextField:
        return StatefulBuilder(
          builder: (context, setState) {
            // Ensure selectedAnswer is a Map
            selectedAnswer ??= {};

            if (widget.options == null || widget.options!.isEmpty) {
              return const Text("No options available");
            }

            return SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: widget.options?.length ?? 0, // Fix null issue
                itemBuilder: (context, index) {
                  String option = widget.options![index];

                  controllers.putIfAbsent(
                    option,
                    () => TextEditingController(
                      text: selectedAnswer[option] ?? "",
                    ),
                  );

                  return ListTile(
                    title: Row(
                      children: [
                        Expanded(child: Text(option)),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: controllers[option],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              selectedAnswer[option] = value;
                              widget.onAnswerSelected(selectedAnswer);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );

      case QuestionType.yesNo:
        return StatefulBuilder(
          builder: (context, setState) {
            return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                backgroundColor: selectedAnswer == "yes" ? Colors.blue : null,
                foregroundColor: selectedAnswer == "yes" ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    selectedAnswer = "yes";
                  });
                  widget.onAnswerSelected("yes");
                },
                child: const Text("Yes"),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedAnswer == "no" ? Colors.blue: null,
                  foregroundColor: selectedAnswer == "no" ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    selectedAnswer = "no";
                  });
                  widget.onAnswerSelected("no");
                },
                child: const Text("No"),
              ),
            ],
          );
        },
      );
    }
  }
}
