import 'dart:convert';

import 'package:athena/screens/joblistings/joblistings.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const apiKey = 'AIzaSyD2Vi6H-b2WpI7wqGNerCtPeFJRws65JEc';
const endText = "INTERVIEW OVER";

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key, required this.job});

  final Job job;

  @override
  InterviewState createState() => InterviewState();
}

class InterviewState extends State<InterviewScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Future<String>> _messages = [];
  late GenerativeModel model;
  late ChatSession chat;
  bool isOver = false;
  bool awaitAnswer = false;
  

  @override
  void initState() {
    super.initState();

    String instructions = """
      You are an interviewer for the following job:
      Job Title: ${widget.job.title}
      Company: ${widget.job.title}
      Job Description: ${widget.job.description}
      Salary: ${widget.job.salary}
      Location: ${widget.job.location}

      Now you have the job details, Act as the hiring manager and interview me for this role. Ask me questions relevant to the position one by one, like in a real interview. If the interview is to be over, say exactly "$endText", then provide feedback targetted towards me for my answers. The feedback should follow the following JSON schema: {"feedback": "x", "rating": "x/10"}. 
    """;

    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      systemInstruction: Content.system(instructions)
    );

    chat = model.startChat();
    _messages.add(_generateResponse("Hello"));
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add(Future.value(text));
        _messages.add(_generateResponse(text));
        awaitAnswer = false;
      });
      _controller.clear();
    }
  }

  Future<String> _generateResponse(String input) async {
    final response = await chat.sendMessage(Content.text(input));

    if (response.text == null) {
      return Future.error(Exception("Response is null"));
    }

    String reply = response.text!;

    if (reply.contains(endText)) {
      Match? match = RegExp(
        r'(\{\s*[\s\S]*?\s*\})',
      ).firstMatch(response.text!);

      if (match == null) {
        return Future.error("Response text formatted incorrectly");
      }

      reply = match.group(1)!.trim();
      setState(() {
        isOver = true;
      });
    }

    setState(() {
      awaitAnswer = true;
    });

    return reply;
  }

  Widget _buildMessage(Future<String> futureMessage, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: FutureBuilder(
          future: futureMessage, 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("...");
            } else if (snapshot.hasError) {
              return Text("Error");
            } else {
              return Text(
                snapshot.data!,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                ),
              );
            }
          }
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Interview Simulation"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          }, 
          icon: Icon(Icons.close),
        ),
      ),
      body: isOver? Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          // child: Text(_messages[_messages.length-1])
          child: FutureBuilder(
            future: _messages[_messages.length-1], 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error");
              } else {
                Map<String, dynamic> data = jsonDecode(snapshot.data!);

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        "Feedback",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(20.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(data['feedback'], style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text("Rating: ${data['rating']}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => {
                              Navigator.pushReplacement(
                                context, 
                                MaterialPageRoute(builder: (context) => InterviewScreen(job: widget.job)),
                              )
                            },
                            child: Text("Try Again"),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            }
          ),
        ),
      )
      : Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[_messages.length - 1 - index];
                return _buildMessage(msg, (index % 2) == 1); 
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: awaitAnswer,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: awaitAnswer ? _sendMessage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}