import 'package:athena/screens/questions/forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'dart:collection';

final logger = Logger();
List<String> hobbiesList = [
  "Fishing",
  "Coffee Making",
  "Running",
  "Drone Flying",
];
List<String> subjectList = [
  "Math",
  "Science",
  "English",
  "Computer Science/ICT",
  "Business",
];

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => QuestionScreenState();
}

class QuestionScreenState extends State<QuestionScreen>
    with TickerProviderStateMixin {
  late PageController _pageViewController;
  int _currentPageIndex = 0;
  final int _totalPages = 6;

  // Answers
  final Map<int, dynamic> _answers = SplayTreeMap<int, dynamic>();

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _answers[3] ??= {for (var subject in subjectList) subject: ""};
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
              QuestionWidget(
                question: "What is your age",
                type: QuestionType.textField,
                onAnswerSelected: (answer) => _answers[0] = answer,
                initialAnswer: _answers[0],
                hintText: "Enter your age",
                format: [FilteringTextInputFormatter.digitsOnly],
              ),
              QuestionWidget(
                question: "Are you a student",
                type: QuestionType.yesNo,
                onAnswerSelected: (answer) => _answers[1] = answer,
                initialAnswer: _answers[1],
              ),
              QuestionWidget(
                question: "What is your education level",
                type: QuestionType.textField,
                onAnswerSelected: (answer) => _answers[2] = answer,
                initialAnswer: _answers[2],
                hintText: "Enter your education level",
              ),
              QuestionWidget(
                question: "List your subject and scores",
                type: QuestionType.multipleTextField,
                options: _answers[3]?.keys.toList() ?? [],
                onAnswerSelected: (answer) {
                  setState(() {
                    _answers[3] = answer;
                  });
                },
                initialAnswer: _answers[3],
                hintText: "Add new subjects here",
              ),
              QuestionWidget(
                question: "List your hobbies and interest",
                type: QuestionType.multipleChoice,
                options: hobbiesList,
                onAnswerSelected: (answer) => _answers[4] = answer,
                initialAnswer: _answers[4],
                hintText: "Add new hobbies/interest here",
              ),
              QuestionWidget(
                question: "What is your dream",
                type: QuestionType.textField,
                onAnswerSelected: (answer) => _answers[5] = answer,
                initialAnswer: _answers[5],
                hintText: "Enter your dream",
              ),
            ],
          ),
          navigationButtons(),
        ],
      ),
    );
  }

  Widget navigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          ElevatedButton(
            onPressed: _currentPageIndex == 0 ? null : _prevPage,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            child: const Icon(Icons.arrow_back),
          ),
          // Next/Submit Button
          ElevatedButton(
            onPressed: _currentPageIndex == _totalPages - 1 ? _submit : _nextPage,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            child: Icon(
              _currentPageIndex == _totalPages - 1
                  ? Icons.check
                  : Icons.arrow_forward,
            ),
          ),
        ],
      ),
    );
  }
}
