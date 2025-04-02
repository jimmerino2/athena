import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final String? hintText;
  final List<TextInputFormatter>? format;
  final bool required;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.type,
    this.options,
    required this.onAnswerSelected,
    this.initialAnswer,
    this.hintText,
    this.format,
    this.required = false,
  });

  @override
  State<QuestionWidget> createState() => QuestionWidgetState();
}

class QuestionWidgetState extends State<QuestionWidget> {
  dynamic selectedAnswer;
  late TextEditingController _textController;
  Map<String, TextEditingController> controllers = {};
  String? _errorText;

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

    /*
    @override
    void dispose() {
      _textController.dispose();
      for (var controller in controllers.values) {
        controller.dispose();
      }
      super.dispose();
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 12.0,
            ),
            child: Text(
              widget.question,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionInput(),
        ],
      ),
    );
  }

  Widget _buildQuestionInput() {
    switch (widget.type) {
      case QuestionType.textField:
        return Column(
          children: [
            TextField(
              controller: _textController,
              inputFormatters: widget.format,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: widget.hintText,
                errorText: _errorText,
              ),
              onChanged: (value) {
                setState(() {
                  selectedAnswer = value;
                  _errorText = value.isEmpty ? "This field is required" : null;
                });
                widget.onAnswerSelected(value);
              },
            ),
          ],
        );


      case QuestionType.dropdown:
        return DropdownButtonFormField<String>(
          value: (selectedAnswer is String) ? selectedAnswer : null,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items:
              widget.options
                  ?.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  })
                  .whereType<DropdownMenuItem<String>>()
                  .toList(),
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
            TextEditingController optionController = TextEditingController();
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35.0),
                  child: SizedBox(
                    height: 250,
                    child: ListView.builder(
                      itemCount: widget.options!.length,
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: optionController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: widget.hintText,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          if (optionController.text.isNotEmpty) {
                            setState(() {
                              widget.options!.add(optionController.text);
                            });
                            optionController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );

      case QuestionType.multipleTextField:
        return StatefulBuilder(
          builder: (context, setState) {
            selectedAnswer ??= {};

            if (widget.options != null) {
              for (var title in widget.options!) {
                selectedAnswer.putIfAbsent(
                  title,
                  () => "",
                ); // Initialize empty score
                controllers.putIfAbsent(
                  title,
                  () => TextEditingController(text: selectedAnswer[title]),
                );
              }
            }

            TextEditingController titleController = TextEditingController();

            List<String> titleList =
                (selectedAnswer is Map)
                    ? selectedAnswer.keys.whereType<String>().toList()
                    : [];
            return Column(
              children: [
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    itemCount: titleList.length,
                    itemBuilder: (context, index) {
                      String title = titleList[index];

                      controllers.putIfAbsent(
                        title,
                        () =>
                            TextEditingController(text: selectedAnswer[title]),
                      );

                      return ListTile(
                        title: Row(
                          children: [
                            Expanded(child: Text(title)),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: controllers[title],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  selectedAnswer[title] = value;
                                  widget.onAnswerSelected(selectedAnswer);
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                //color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedAnswer.remove(title);
                                  controllers.remove(title);
                                });
                                widget.onAnswerSelected(selectedAnswer);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: widget.hintText,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          //color: Colors.green,
                        ),
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            String newTitle = titleController.text.trim();
                            if (!selectedAnswer.containsKey(newTitle)) {
                              setState(() {
                                selectedAnswer[newTitle] = "";
                                controllers[newTitle] = TextEditingController();
                                widget.onAnswerSelected(selectedAnswer);
                              });
                            }
                            titleController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
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
                    minimumSize: const Size(100, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor:
                        selectedAnswer == "yes" ? Colors.blue : null,
                    foregroundColor:
                        selectedAnswer == "yes" ? Colors.white : Colors.black,
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
                    minimumSize: const Size(100, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor:
                        selectedAnswer == "no" ? Colors.blue : null,
                    foregroundColor:
                        selectedAnswer == "no" ? Colors.white : Colors.black,
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
