import 'dart:convert';
import 'dart:typed_data';
import 'package:athena/screens/profile/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:athena/services/firestore.dart';

const apiKey = 'AIzaSyD2Vi6H-b2WpI7wqGNerCtPeFJRws65JEc';

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  List<Uint8List> images = [];
  bool isUploaded = false;

  Future<void> uploadResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath!.endsWith('.pdf')) {
        final pdf = PdfImageRenderer(path: filePath);
        await pdf.open();

        int totalPages = await pdf.getPageCount();
        if (totalPages <= 3) {
          for (int i = 0; i < totalPages; i++) {
            await pdf.openPage(pageIndex: i);
            var size = await pdf.getPageSize(pageIndex: i);
            var img = await pdf.renderPage(
              pageIndex: i,
              x: 0,
              y: 0,
              width: size.width,
              height: size.height,
              scale: 1,
              background: Colors.white,
            );
            await pdf.closePage(pageIndex: i);
            pdf.close();

            setState(() {
              images.add(img!);
              isUploaded = true;
            });
          }
        } else {
          // Too many pages
          Fluttertoast.showToast(
            msg: "Pdf must contain at most 3 pages.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0,
          );
        }
      } else {
        // Invalid file format
        Fluttertoast.showToast(
          msg: "Please submit file in .pdf format.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      }
    } else {
      // No file submitted
      Fluttertoast.showToast(
        msg: "No file submitted.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),

        child:
            !isUploaded
                ?
                // Before Upload
                Column(
                  children: [
                    Text(
                      "Upload your resume",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Gemini AI will evaluate it and give you tips to improve it!",
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: uploadResume,
                      child: Text("Upload Resume"),
                    ),
                  ],
                )
                // After Upload
                : ResumeResults(images: images),
      ),
    );
  }
}

class ResumeResults extends StatefulWidget {
  final List<Uint8List> images;

  const ResumeResults({super.key, required this.images});

  @override
  State<ResumeResults> createState() => _ResumeResultsState();
}

class _ResumeResultsState extends State<ResumeResults> {
  List<Widget> displayImages(List<Uint8List> imageBytesList) {
    return imageBytesList.map((bytes) {
      return Image.memory(bytes);
    }).toList();
  }

  Future<Map<String, dynamic>> generateResults() async {
    String chosenJob = await FirestoreService().getChosenJob(
      FirebaseAuth.instance.currentUser!.uid,
    );
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );

    String prompt =
        """Based on the resume images sent, suggest a score out of 10 (.5s are allowed) given they are applying for a $chosenJob job.
        Furthermore, give up to 5 pros, cons and recommendations for the resume.
        Send the data in the following format with no extra text:
        
      {"score": x, "Strengths": ["x","x"], 'Weaknesses':["x","x"], "Tips":["x","x"]}
        """;

    final content = [
      Content.text(prompt),
      for (var image in widget.images) Content.data('image/jpeg', image),
    ];

    final response = await model.generateContent(content.cast<Content>());

    String rawText = response.text ?? "";
    String cleanedJson = rawText.replaceAll(RegExp(r'```json|```'), '').trim();

    if (!cleanedJson.startsWith("{")) {
      cleanedJson = cleanedJson.substring(cleanedJson.indexOf("{"));
    }
    if (!cleanedJson.endsWith("}")) {
      cleanedJson = cleanedJson.substring(0, cleanedJson.lastIndexOf("}") + 1);
    }

    return jsonDecode(cleanedJson);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: generateResults(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Evaluating Resume...", style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading evaluation.",
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "No data available.",
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          );
        }

        final evaluation = snapshot.data as Map<String, dynamic>;
        final titles = ['Strengths', 'Weaknesses', 'Tips'];

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 525,
                child: Stack(
                  children: [
                    Center(
                      child: Column(children: displayImages(widget.images)),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(24),
                        child: Text(
                          "${evaluation["score"]}/10",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  // Add your actual content here
                  for (var title in titles) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Column(
                      children: List.generate(evaluation[title].length, (
                        index,
                      ) {
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 1.0),
                          leading: Icon(Icons.arrow_right),
                          title: Text(
                            evaluation[title][index],
                            style: TextStyle(fontSize: 15),
                          ),
                        );
                      }),
                    ),
                  ],
                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
