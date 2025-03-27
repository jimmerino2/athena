import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:collection';

enum QuestionType { textField, dropdown, multipleChoice, yesNo, multipleTextField}
final logger = Logger();
List<String> hobbiesList = ["Fishing", "Coffee Making", "Running", "Drone Flying"];
List<String> subjectList = ["Math", "Science", "English", "Computer Science/ICT", "Business"];
class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => QuestionScreenState();
}

class QuestionScreenState extends State<QuestionScreen> with TickerProviderStateMixin {
  late PageController _pageViewController;
  int _currentPageIndex = 0;
  final int _totalPages = 6;

  // Answers
  final Map<int, dynamic> _answers = SplayTreeMap<int, dynamic>(); 

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPageIndex < _totalPages - 1) {
      int nextPage = _currentPageIndex + 1;
      if (_currentPageIndex == 1 && _answers[1] == "no") {
        nextPage = 4; // Skip to "Hobbies and Interests"
      }
      _pageViewController.jumpToPage(
        nextPage,
        // duration: const Duration(milliseconds: 200),
        // curve: Curves.easeInOut,
      );
      setState(() {
        _currentPageIndex = nextPage;
      });
    }
  }

  void _prevPage() {
    if (_currentPageIndex > 0) {
      int previousPage = _currentPageIndex - 1;
      if (_currentPageIndex == 4 && _answers[1] == "no") {
        previousPage = 1;
      }
      _pageViewController.jumpToPage(previousPage);
      setState(() {
        _currentPageIndex = previousPage;
      });
    }
  }

  void _submit() {
    Map<String, dynamic> result = {
      "Age": _answers[0],
      "Student": _answers[1] == "yes" ? "Yes" : "No",
      "Education Level": _answers[2],
      "Subjects & Scores": _answers[3],
      "Hobbies & Interests": _answers[4],
      "Dream": _answers[5],
    };

    logger.i("Submitted Answers: $result");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Questions')),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          PageView(
            controller: _pageViewController,
            children: <Widget>[
              QuestionWidget(question: "What is your age", type: QuestionType.textField, onAnswerSelected: (answer) => _answers[0] = answer, initialAnswer: _answers[0],),
              QuestionWidget(question: "Are you a student", type: QuestionType.yesNo, onAnswerSelected: (answer) => _answers[1] = answer, initialAnswer: _answers[1],),
              QuestionWidget(question: "What is your education level", type: QuestionType.textField, onAnswerSelected: (answer) => _answers[2] = answer, initialAnswer: _answers[2],),
              QuestionWidget(question: "List your subject and scores", type: QuestionType.multipleTextField, onAnswerSelected: (answer) => _answers[3] = answer, initialAnswer: _answers[3],),
              QuestionWidget(question: "List your hobbies and interest", type: QuestionType.multipleChoice, onAnswerSelected: (answer) => _answers[4] = answer, initialAnswer: _answers[4],),
              QuestionWidget(question: "What is your dream", type: QuestionType.textField, onAnswerSelected: (answer) => _answers[5] = answer, initialAnswer: _answers[5],)
            ],
          ),
        navigationButtons(),
        ],
      ),
    );
  }

  Widget navigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          ElevatedButton(
            onPressed: _currentPageIndex == 0 ? null : _prevPage,
            child: const Text("Previous"),
          ),

          // Next/Submit Button
          ElevatedButton(
            onPressed: _currentPageIndex == _totalPages - 1 ? _submit : _nextPage,
            child: Text(_currentPageIndex == _totalPages - 1 ? "Submit" : "Next"),
          ),
        ],
      ),
    );
  }
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

class QuestionWidgetState extends State<QuestionWidget>{
  dynamic selectedAnswer;
  late TextEditingController _textController;
  Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    selectedAnswer = widget.initialAnswer;
    _textController = TextEditingController(text: widget.initialAnswer?.toString() ?? "");
    selectedAnswer = widget.initialAnswer ?? {};

    for (var subject in subjectList) {
      controllers[subject] = TextEditingController(
        text: (selectedAnswer is Map && selectedAnswer.containsKey(subject))
            ? selectedAnswer[subject]
            : "",
      );
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
          Text(
          widget.question,
          style: Theme.of(context).textTheme.titleLarge),
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
          items: widget.options?.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (String? value) {
            setState((){
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
                itemCount: hobbiesList.length,
                itemBuilder: (context, index) {
                  final hobby = hobbiesList[index];
                  final isSelected = selectedAnswer.contains(hobby);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedAnswer.remove(hobby);
                        } else {
                          selectedAnswer.add(hobby);
                        }
                      });
                      widget.onAnswerSelected(selectedAnswer);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey : Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        hobby,
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
          //   selectedAnswer ??= {};

          // // Store controllers for each subject
          // Map<String, TextEditingController> controllers = {
          //   for (var subject in subjectList)
          //     subject: TextEditingController(text: selectedAnswer[subject] ?? "")
          // };
            return SizedBox(
              height: 300, // Set a fixed height to make it scrollable
              child: ListView.builder(
                itemCount: subjectList.length,  // Number of items in the list
                itemBuilder: (context, index) {
                  String subject = subjectList[index];
                  selectedAnswer.putIfAbsent(subject, () => "");
                  return ListTile(
                    title:Row(
                      children: [
                        Expanded(
                          child: Text(subject), 
                        ),
                        SizedBox(width:10),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: controllers[subject],
                            decoration: InputDecoration(
                            border:OutlineInputBorder(),
                            ),
                            onChanged: (value){
                              selectedAnswer[subject] = value;
                              widget.onAnswerSelected(selectedAnswer);
                            },
                          ))
                      ],
                    ),
                  );
                },
              )
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