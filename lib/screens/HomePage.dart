import 'package:flutter/material.dart';
import 'package:sentiment_dart/sentiment_dart.dart';
import 'package:foodcateringwithsentimentanalysis/loadlexicon/fileClass.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController commentController = TextEditingController();
  SentimentResult result = Sentiment.analysis("h");
  final LexiconStorage lexiconStorage = LexiconStorage();
  var newWords = {'genius': 5.2};

  @override
  void initState() {
    super.initState();
    _loadLexicon();
  }

  void analyzeComment(String inputText) {
    setState(() {
      result = Sentiment.analysis(inputText, customLang: newWords);
      print(result);
    });
  }

  void _loadLexicon() async {
    final lexicon = await lexiconStorage.readLexicon();
    if (mounted) {
      setState(() {
        print(lexicon);
      });
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
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
