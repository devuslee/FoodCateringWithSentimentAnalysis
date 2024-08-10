import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableWidgets.dart';
import 'package:sentiment_dart/sentiment_dart.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:huggingface_dart/huggingface_dart.dart';

import '../reusableWidgets/reusableFunctions.dart';
import 'CommentsPage.dart';

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

  Map<String, List<Map<String, dynamic>>> reviews = {};
  List menu = [];
  double rating = 0.0;
  double totalSale = 0.0;

  int totalReviews = 0;


  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      String vaderData = await rootBundle.loadString('/vader_lexicon.txt');
      parseLexiconData(vaderData);

      menu = await getMenu();
      rating = await returnTodayRating();
      totalReviews = await returnTodayTotalReview();
      totalSale = await returnTodaySale();



      if (mounted) {
        setState(() {
          reviews = reviews;
          menu = menu;
          rating = rating;
          totalSale = totalSale;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  //parsing vader lexicon
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

  //smiling face sentiment analysis
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
        print("Smiling face Sentimental Analysis: ${response}");
      });
    } catch (e) {
      print('Error occurred: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ReusableAppBar(title: "Analysis", backButton: false),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.height * 0.2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text("Rating"),
                    IgnorePointer(
                        ignoring: true,
                        child: RatingBar.builder(
                          initialRating: rating,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: MediaQuery.of(context).size.height * 0.040,
                          itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            print(rating);
                          },
                        )
                    ),
                    Text("${rating}", style: TextStyle(
                      color: Colors.amber,
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                    ),),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.height * 0.2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text("Total Reviews",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: MediaQuery.of(context).size.height * 0.025,
                      ),
                    ),
                    Text("${totalReviews}",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.height * 0.05,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CommentsPage()),
                        );
                      },
                      child: Text("Read Comment"),
                    ),

                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.height * 0.2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text("Total Sales",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: MediaQuery.of(context).size.height * 0.025,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Text("RM${totalSale}",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.height * 0.05,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
        ),
      )
    );
  }
}
