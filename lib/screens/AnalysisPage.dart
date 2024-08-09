import 'package:flutter/material.dart';
import 'package:sentiment_dart/sentiment_dart.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:huggingface_dart/huggingface_dart.dart';

HfInference hfInference = HfInference('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');

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
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
  }

  void analyzeComment(String inputText) async {
    try {
      final response = await hfInference.fillMask(
        model: 'cardiffnlp/twitter-roberta-base-sentiment',
        inputs: [inputText],
      );

      //improved version
      Map<String, String> labelMapping = {
        'LABEL_0': 'negative',
        'LABEL_1': 'neutral',
        'LABEL_2': 'positive',
      };

      for (var i = 0; i < response[0].length; i++) {
        String label = response[0][i]['label'];
        if (labelMapping.containsKey(label)) {
          response[0][i]['label'] = labelMapping[label];
        }
      }



      setState(() {
        result = Sentiment.analysis(inputText, customLang: newWords);
        print("Vader Sentimental Analysis: ${result}");
        print("Vader Sentimental Analysis: ${response}");
      });
    } catch (e) {
      print('Error occurred: $e');
    }
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
