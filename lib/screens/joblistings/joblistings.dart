import 'package:athena/services/auth.dart';
import 'package:athena/services/firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

class Job {
  final String id;
  final String title;
  final String company;
  final String description;
  final String location;
  final String salary;
  final String age;
  final String logoUrl;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    required this.location,
    required this.salary,
    required this.age,
    required this.logoUrl,
  });

  factory Job.fromList(List<String> list) => Job(
    id: list[0],
    title: list[1],
    company: list[2],
    description: list[3],
    location: list[4],
    salary: list[5],
    age: list[6],
    logoUrl: list[7],
  );
}

class JobListingRepository {
  static final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: 'AIzaSyD2Vi6H-b2WpI7wqGNerCtPeFJRws65JEc',
  );

  static Future<List<Job>>? _jobs;

  static List<Job> _scrapeJobs(String html) {
    dom.Document document = parse(html);

    List<Job> jobs = [];

    List<dom.Element> jobElements = document.querySelectorAll(
      '[data-testid="job-card"]',
    );

    for (var element in jobElements) {
      String id = element.attributes['data-job-id'] ?? 'Unknown';
      String title =
          element.querySelector('[data-automation="jobTitle"]')?.text ?? 'N/A';
      String company =
          element.querySelector('[data-automation="jobCompany"]')?.text ??
          'N/A';
      String description =
          element
              .querySelector('[data-automation="jobShortDescription"]')
              ?.text ??
          'N/A';
      String location =
          element.querySelector('[data-automation="jobLocation"]')?.text ??
          'N/A';
      String salary =
          element.querySelector('[data-automation="jobSalary"]')?.text ?? 'N/A';
      String listingAge =
          element.querySelector('[data-automation="jobListingDate"]')?.text ??
          'N/A';
      String logoUrl =
          element
              .querySelector('[data-automation="company-logo"] img')
              ?.attributes['src'] ??
          "https://placehold.co/40x40/png";

      jobs.add(
        Job.fromList([
          id,
          title,
          company,
          description,
          location,
          salary,
          listingAge,
          logoUrl,
        ]),
      );
    }

    return jobs;
  }

  static Future<List<Job>> _fetchJobs() async {
    final chosenJob = (await FirestoreService().getChosenJob(
      AuthService().user?.uid ?? "",
    )).replaceAll(RegExp(r"\(|\/|\)| "), "-"); // Replace parenthesis, slashes and spaces with '-'

    final url = Uri.parse('https://www.seek.com.au/$chosenJob-jobs');
    // final url = Uri.parse('https://example.com');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return (_scrapeJobs(response.body));
    } else {
      return Future.error("Failed to fetch jobs: ${response.statusCode}");
    }
  }

  static Future<List<Job>> fetchJobListing() {
    _jobs ??= _fetchJobs();
    return _jobs!;
  }

  static Future<List<Job>> refreshJobListing() {
    _jobs = _fetchJobs();
    return _jobs!;
  }
}

class JobListingsScreen extends StatefulWidget {
  const JobListingsScreen({super.key});

  @override
  State<JobListingsScreen> createState() => _JobListingsScreenState();
}

class _JobListingsScreenState extends State<JobListingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text("Job Listing", style: TextStyle(fontSize: 28)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                onPressed:
                    () => setState(() {
                      JobListingRepository.refreshJobListing();
                    }),
                icon: Icon(Icons.refresh),
              ),
            ),
          ],
        ),
        FutureBuilder(
          future: JobListingRepository.fetchJobListing(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // handle error
              return Text("Error: ${snapshot.error}");
            } else {
              List<Job> jobs = snapshot.data!;
              return Expanded(
                child: ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    Job job = jobs[index];
                    return Column(
                      children: [LargeJobCard(job: job), SizedBox(height: 20)],
                    );
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class LargeJobCard extends StatelessWidget {
  const LargeJobCard({super.key, required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    // border: Border.all(),
                    shape: BoxShape.circle,
                    image: DecorationImage(image: NetworkImage(job.logoUrl)),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(job.company, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                // Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [Text(job.age), Text(job.location)],
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(job.description),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(job.salary, overflow: TextOverflow.ellipsis)),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8.0)),
                ElevatedButton(
                  onPressed:
                      () async => await launchUrl(
                        Uri.parse("https://www.seek.com.au/job/${job.id}"),
                      ),
                  child: Text("Open"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
