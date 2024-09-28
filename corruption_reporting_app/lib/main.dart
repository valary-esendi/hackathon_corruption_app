import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// Make sure to include url_launcher in your pubspec.yaml dependencies
void main() {
  runApp(const CorruptionReportingApp());
}

// Main application widget
class CorruptionReportingApp extends StatelessWidget {
  const CorruptionReportingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corruption Reporting App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color.fromARGB(255, 54, 33, 243),
      ),
      home: const ReportPage(),
    );
  }
}

// ReportPage - where users can submit and manage reports
class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  String _report = '';
  List<String> _storedReports = []; // Store submitted reports

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  // Load reports from SharedPreferences
  Future<void> _loadReports() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? reports = prefs.getStringList('reports') ?? [];
      setState(() {
        _storedReports = reports; // Load reports for displaying
      });
    } catch (e) {
      // Handle error in loading data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reports: $e')),
      );
    }
  }

  // Save report to SharedPreferences
  Future<void> _saveReport() async {
    if (_formKey.currentState!.validate()) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String>? reports = prefs.getStringList('reports') ?? [];
        reports.add(_report); // Store the new report

        await prefs.setStringList('reports', reports);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!')),
        );
        _formKey.currentState!.reset();
        _loadReports(); // Reload reports to update the UI
      } catch (e) {
        // Handle errors while saving reports
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving report: $e')),
        );
      }
    }
  }

  // Edit an existing report based on its index
  Future<void> _editReport(int index) async {
    String newReport = await _showEditDialog(_storedReports[index]);
    if (newReport.isNotEmpty) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        _storedReports[index] = newReport;
        await prefs.setStringList('reports', _storedReports);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report updated successfully!')),
        );
        _loadReports();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating report: $e')),
        );
      }
    }
  }

  // Show a dialog to edit the report
  Future<String> _showEditDialog(String existingReport) async {
    String newReport = existingReport;
    final TextEditingController controller =
        TextEditingController(text: existingReport);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Report',
              style: TextStyle(color: Color.fromARGB(255, 54, 33, 243))),
          content: TextField(
            controller: controller,
            decoration:
                const InputDecoration(hintText: 'Enter new report description'),
            onChanged: (value) {
              newReport = value;
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return newReport;
  }

  // Delete a report
  Future<void> _deleteReport(int index) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _storedReports.removeAt(index);
      await prefs.setStringList('reports', _storedReports);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report deleted successfully!')),
      );
      _loadReports(); // Reload reports to update the UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting report: $e')),
      );
    }
  }

  // Build the report list with edit and delete options
  Widget _buildReportList() {
    return ListView.builder(
      itemCount: _storedReports.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_storedReports[index],
              style: const TextStyle(color: Color.fromARGB(255, 54, 33, 243))),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                      const Color.fromARGB(255, 54, 33, 243)),
                  foregroundColor: WidgetStateProperty.all(Colors.black),
                ),
                onPressed: () => _editReport(index),
                child: const Text("Edit"),
              ),
              const SizedBox(width: 8), // Space between buttons
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                  foregroundColor: WidgetStateProperty.all(Colors.black),
                ),
                onPressed: () => _deleteReport(index),
                child: const Text("Delete"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to launch the URL
  Future<void> _launchURL() async {
    const url =
        'https://www.transparency.org/en/what-is-corruption'; // Example URL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Corruption',
            style: TextStyle(color: Color.fromARGB(255, 54, 33, 243))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    style: const TextStyle(
                        color: Color.fromARGB(
                            255, 54, 33, 243)), // Text color for input field
                    decoration: const InputDecoration(
                      labelText: 'Describe the incident',
                      labelStyle: TextStyle(
                          color: Color.fromARGB(
                              255, 54, 33, 243)), // Label color
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(
                                255, 54, 33, 243)), // Focused border color
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _report = value; // Update the report text
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          const Color.fromARGB(255, 54, 33, 243)),
                      foregroundColor: WidgetStateProperty.all(Colors.black),
                    ),
                    onPressed: _saveReport,
                    child: const Text('Submit Report'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'Submitted Reports:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 54, 33, 243)),
                  ),
                  Expanded(
                      child: _buildReportList()), // Display the list of reports
                ],
              ),
            ),
            // Section for images and link
            const SizedBox(height: 16),
            const Text(
              'Learn More About Combating Corruption:',
              style: TextStyle(
                  fontSize: 18, color: Color.fromARGB(255, 54, 33, 243)),
            ),
            const SizedBox(height: 8),
            // Add images and link
            Image.asset('assets/images/corruption_image1.png',
                height: 100, width: 100), // Change the path accordingly
            const SizedBox(height: 8),
            Image.asset('assets/images/corruption_image2.png',
                height: 100, width: 100), // Change the path accordingly
            const SizedBox(height: 8),
            TextButton(
              onPressed: _launchURL,
              child: const Text(
                'What is Corruption?',
                style: TextStyle(
                    color: Color.fromARGB(255, 54, 33, 243),
                    decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
