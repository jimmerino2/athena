import 'package:flutter/material.dart';

class QuestionScreen extends StatefulWidget{
  const QuestionScreen({super.key, required this.title});
  final String title;

  @override
  _QuestionPageState createState() => _QuestionPageState();
}
class _QuestionPageState extends State<QuestionScreen>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body:Center(
        child:Text('What is your age')
      )
    );
  }
}