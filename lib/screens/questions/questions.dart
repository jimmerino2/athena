import 'package:flutter/material.dart';

class QuestionScreen extends StatelessWidget {
  const QuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Questions')),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/courses');
                },
                child: Text('Courses'),
              ),
            ),
            Flexible(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/gemini');
                },
                child: Text('Gemini Testing'),
              ),
            ),
            Flexible(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/questionPages');
                },
                child: Text('Question Basic Pages'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
