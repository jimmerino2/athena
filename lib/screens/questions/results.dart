import 'dart:convert';

import 'package:athena/layout/nav_sidebar.dart';
import 'package:athena/services/auth.dart';
import 'package:athena/services/firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const apiKey = 'AIzaSyD2Vi6H-b2WpI7wqGNerCtPeFJRws65JEc';

class ResultsScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const ResultsScreen({super.key, required this.result});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );

  Future<List<Map<String, dynamic>>> fetchData() async {
    await Future.delayed(Duration(seconds: 3));

    String prompt =
        """Suggest 15 jobs and a boolean indicating if the job is expected to prosper in the future.
            Ensure at least 2 jobs are not expected to prosper. 
            The individual has the following results in a quiz taken:
            ${widget.result}
            Order the jobs as the first being the most suitable based on the quiz results, while the last being the least.
            Ensure that the jobs recommended correlate to the quiz. 

            Return the result as a JSON array with no extra text. 
            Example: [{'job': 'Lawyer', 'isProsper': false}]""";
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    String cleanedText =
        response.text!.replaceAll("```json", "").replaceAll("```", "").trim();

    List<Map<String, dynamic>> jobs = List<Map<String, dynamic>>.from(
      jsonDecode(
        cleanedText,
      ).map((job) => {'job': job['job'], 'isProsper': job['isProsper']}),
    );
    return jobs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Text(
                            "Figuring out your ideal job...",
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        SizedBox(height: 20),
                        CircularProgressIndicator(),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text("Error generating jobs.");
                  } else {
                    List<Map<String, dynamic>> jobs = snapshot.data ?? [];
                    return Expanded(
                      child: SingleChildScrollView(
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    "Job Suggestions",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                ListTile(
                                  title: Text("Job Title"),
                                  trailing: Text("Future Prospect"),
                                ),
                                SizedBox(height: 10),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: jobs.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(
                                              context,
                                            ).secondaryHeaderColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      margin: const EdgeInsets.all(2.0),
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: ListTile(
                                          title: Text(jobs[index]['job']),
                                          trailing: Icon(
                                            jobs[index]['isProsper']
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color:
                                                jobs[index]['isProsper']
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) => ResultsDescription(
                                                      result: widget.result,
                                                      job: jobs[index]['job'],
                                                      isProsper:
                                                          jobs[index]['isProsper'],
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 80),
                              ],
                            ),
                            Positioned(
                              bottom: 20,
                              right: 20,
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("To Home"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultsDescription extends StatelessWidget {
  final String job;
  final bool isProsper;
  final Map<String, dynamic> result;

  Future<Map<String, dynamic>> generateDetails() async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );

    String prompt = """
      Provide the following regarding the job title: $job, given that the job will ${isProsper ? "" : "not "} prosper in the future.
      [summary, requirements, why is the job suitable for the user, why will it or not prosper in the future, income in RM].
      Keep note that the user got the following results from a quiz : $result.
      Keep the data in String form.
      Keep requirements brief and purely in text, not point form, being mindful they may only be high school education.
      Keep the income section as a range. eg: '1000\$ USD to 2000\$ USD, while mentioning hourly, monthly and yearly.' 
      Keep each section under 100 words.

      Return the result as an object with no extra text. 
      Example: {'summary': 'xxxxx', 'requirements': 'xxxxxx', 'suitable': 'xxxxxx', 'prospect': 'xxxxx', 'income': ['hourly': 'xxx', 'monthly': 'xxx', 'yearly': 'xxx'] }""";
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

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

  const ResultsDescription({
    super.key,
    required this.job,
    required this.isProsper,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<Map<String, dynamic>>(
              future: generateDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        "Fetching job details...",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  );
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Text(
                    "Error loading job details.",
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  );
                }

                final jobDetails = snapshot.data!;
                List<Map<String, dynamic>> content = [
                  {'title': 'Summary', 'content': jobDetails['summary']},
                  {
                    'title': 'Requirements',
                    'content': jobDetails['requirements'],
                  },
                  {
                    'title': 'Why this is for you',
                    'content': jobDetails['suitable'],
                  },
                  {
                    'title': 'Future Job Prospect',
                    'content': jobDetails['prospect'],
                  },
                  {
                    'title': 'Expected Income',
                    'content':
                        "Hourly Rate: ${jobDetails['income']['hourly']}\nMonthly Rate: ${jobDetails['income']['monthly']}\nYearly Rate: ${jobDetails['income']['yearly']}",
                  },
                ];
                return ListView(
                  children: [
                    Column(
                      children: [
                        Text(
                          job,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                content.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 20.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'],
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(item['content']),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Back"),
                            ),
                            SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                FirestoreService().setChosenJob(
                                  AuthService().user?.uid ?? "",
                                  job,
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NavSidebarLayout(),
                                  ),
                                );
                              },
                              child: Text("Select Job"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
