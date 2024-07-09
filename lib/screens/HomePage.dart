import 'package:flutter/material.dart';
import 'package:sentiment_dart/sentiment_dart.dart';
import 'package:flutter/services.dart' show rootBundle;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController commentController = TextEditingController();
  SentimentResult result = Sentiment.analysis("h");
  Map<String, double> newWords = {'genius': 5.2, };

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    String vaderData = await rootBundle.loadString('/vader_lexicon.txt');
    parseLexiconData(vaderData);
  }

  void parseLexiconData(String data) {
    final lines = data.split('\n');
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split('\t');
      if (parts.length >= 2) {
        final term = parts[0].trim();
        final score = double.tryParse(parts[1].trim());
        if (score != null) {
          newWords[term] = score;
        }
      }
    }
    setState(() {
      print(newWords);
    });
  }

  void analyzeComment(String inputText) {
    setState(() {
      result = Sentiment.analysis(inputText, customLang: newWords);
      print(result);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentiment Analysis'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Enter a comment to analyze its sentiment:',
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Comment',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  analyzeComment(commentController.text);
                },
                child: const Text('Analyze'),
              ),
              const SizedBox(height: 20),
              Text(
                commentController.text,
              ),
              const SizedBox(height: 20),
              Text(
                'Sentiment: ${result.score}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
