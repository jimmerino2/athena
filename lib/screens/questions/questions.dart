import 'package:athena/screens/questions/forms.dart';
import 'package:athena/screens/questions/results.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:collection';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // No stack trace
    printEmojis: false,
    noBoxingByDefault: true,
  ),
);

List<String> hobbiesList = ["Fishing", "Coffee Making", "Gyming", "Singing"];
List<String> subjectList = [
  "English",
  "Science",
  "Mathematics",
  "Accounting",
  "History",
];

List<Map<String, dynamic>> inputs = [];

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => QuestionScreenState();
}

class QuestionScreenState extends State<QuestionScreen>
    with TickerProviderStateMixin {
  late PageController _pageViewController;
  int _currentPageIndex = 0;
  int _totalPages = 5;

  // Answers
  final Map<int, dynamic> _answers = SplayTreeMap<int, dynamic>();

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _answers[3] ??= {for (var subject in subjectList) subject: ""};

    inputs = [
      {
        'question': 'How old are you',
        'type': QuestionType.textField,
        'selected': (answer) => _answers[0] = answer,
        'hint': "Enter your age",
        'format': [FilteringTextInputFormatter.digitsOnly],
      },
      {
        'question': 'Are you a student',
        'type': QuestionType.yesNo,
        'selected': (answer) => _answers[1] = answer,
      },
      {
        'question': 'What is your education level',
        'type': QuestionType.dropdown,
        'selected': (answer) => _answers[2] = answer,
        'options': ['Primary', 'Secondary', 'Tertiary or Higher'],
        'optional': true,
      },
      {
        'question': 'List your subjects and scores',
        'type': QuestionType.multipleTextField,
        'selected': (answer) {
          setState(() {
            _answers[3] = answer;
          });
        },
        'options': _answers[3]?.keys.toList() ?? [],
        'hint': "Add new items here",
        'optional': true,
      },
      {
        'question': 'How would you describe yourself',
        'type': QuestionType.multipleChoice,
        'options': [
          "Organized",
          "Analytical",
          "Creative",
          "Energetic",
          "Quiet",
          "Adaptable",
          "Independent",
          "Ambitious",
        ],
        'selected': (answer) => _answers[4] = answer,
        'hint': "Add new items here.",
      },
      {
        'question': 'List your hobbies and interests',
        'type': QuestionType.multipleChoice,
        'options': hobbiesList,
        'selected': (answer) => _answers[5] = answer,
        'hint': "Add new items here.",
      },
      {
        'question': 'What skills do you think you have',
        'type': QuestionType.multipleChoice,
        'options': [
          "Writing and communication",
          "Logics and problem solving",
          "Creativity and design",
          "Leadership and shotcalling",
        ],
        'selected': (answer) => _answers[6] = answer,
        'hint': "Add new items here.",
      },
      {
        'question': 'Which role do you think suits you when working in teams',
        'type': QuestionType.multipleChoice,
        'options': [
          "The leader or shotcaller",
          "The mediator or the glue",
          "The quiet genius",
          "The creative thinker",
        ],
        'selected': (answer) => _answers[7] = answer,
        'hint': "Add new items here.",
      },
      {
        'question': 'What type of work environment do you enjoy',
        'type': QuestionType.multipleChoice,
        'options': [
          "Fast-paced and dynamic",
          "Quiet and focused",
          "Collaborative and team-based",
          "Independent and flexible",
        ],
        'selected': (answer) => _answers[8] = answer,
        'hint': "Add new items here.",
      },
      {
        'question': 'Do you enjoy public speaking',
        'type': QuestionType.multipleChoice,
        'options': [
          "Very much",
          "Yes but prefer small groups",
          "No, I'm really shy",
        ],
        'selected': (answer) => _answers[9] = answer,
        'hint': "Add new items here.",
      },
      {
        'question': 'Can you do well under pressure',
        'type': QuestionType.multipleChoice,
        'options': [
          "Confidently yes",
          "Yes, if managable",
          "Not exactly",
          "Not at all",
        ],
        'selected': (answer) => _answers[10] = answer,
        'hint': "Add new items here.",
      },
      {
        'question': 'What is most important to you when finding jobs',
        'type': QuestionType.multipleChoice,
        'options': [
          "Salary and income",
          "Work life balance",
          "Passion and interests",
          "Leadership opportunities",
        ],
        'selected': (answer) => _answers[11] = answer,
        'hint': "Add new items here.",
      },
      {
        'question': 'What industry are you interested in\n(optional)',
        'type': QuestionType.textField,
        'selected': (answer) => _answers[12] = answer,
        'hint': "Optional Question",
      },
    ];
    _totalPages = inputs.length;
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  void _nextPage() {
    print(_answers);
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
    for (int i = 0; i < _totalPages; i++) {
      final item = inputs[i];

      if (item['optional'] != true &&
          (_answers[i] == null || _answers[i].toString().trim().isEmpty)) {
        _pageViewController.jumpToPage(i);
        Fluttertoast.showToast(
          msg: "Please fill in the required questions.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0,
        );
        setState(() {
          _currentPageIndex = i;
        });

        return;
      }
    }

    Map<String, dynamic> result = {
      "Age": _answers[0],
      "Student": _answers[1],
      "Education Level": _answers[2],
      "Subjects & Scores": _answers[3],
      "Personality": _answers[4],
      "Hobbies & Interests": _answers[5],
      "Skills": _answers[6],
      "Role in Teams": _answers[7],
      "Work Environment": _answers[8],
      "Public Speaking": _answers[9],
      "Can take Pressure": _answers[10],
      "Priorities": _answers[11],
      "Industry": _answers[12],
    };

    logger.i("Results: $result");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultsScreen(result: result)),
    );
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
              for (var item in inputs)
                QuestionWidget(
                  question: item['question'],
                  type: item['type'],
                  onAnswerSelected: item['selected'],
                  initialAnswer: _answers[inputs.indexOf(item)] ?? '',
                  hintText: item.containsKey('hint') ? item['hint'] : null,
                  format: item.containsKey('format') ? item['format'] : [],
                  options: item.containsKey('options') ? item['options'] : [],
                  required: item.containsKey('optional') ? false : true,
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
            onPressed:
                _currentPageIndex == _totalPages - 1 ? _submit : _nextPage,
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
