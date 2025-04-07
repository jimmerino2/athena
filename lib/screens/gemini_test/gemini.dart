import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:athena/services/auth.dart';

const apiKey = 'AIzaSyD2Vi6H-b2WpI7wqGNerCtPeFJRws65JEc';

class GeminiScreen extends StatefulWidget {
  const GeminiScreen({super.key});

  @override
  _GeminiScreenState createState() => _GeminiScreenState();
}

class _GeminiScreenState extends State<GeminiScreen> {
  String responseText = "Enter a prompt to generate text.";
  bool isLoading = false;
  String userName = AuthService().user?.displayName ?? "User";

  final TextEditingController controller = TextEditingController();

  Future<void> submitText() async {
    setState(() {
      responseText = "Generating response...";
    });

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );

    String userInput = controller.text;
    final content = [Content.text(userInput)];
    final response = await model.generateContent(content);

    setState(() {
      responseText = response.text ?? "No response received.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gemini AI Story for")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter a prompt"),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Enter prompt",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: submitText,
              child: const Text("Generate"),
            ),
            const SizedBox(height: 20),
            Text(responseText),
          ],
        ),
      ),
    );
  }
}
