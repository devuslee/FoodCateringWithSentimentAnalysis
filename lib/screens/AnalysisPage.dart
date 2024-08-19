import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableWidgets.dart';
import 'package:sentiment_dart/sentiment_dart.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:huggingface_dart/huggingface_dart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:word_cloud/word_cloud.dart';

import 'package:vertical_barchart/extension/expandedSection.dart';
import 'package:vertical_barchart/vertical-barchart.dart';
import 'package:vertical_barchart/vertical-barchartmodel.dart';
import 'package:vertical_barchart/vertical-legend.dart';

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

  Map<String, List<Map<String, dynamic>>> reviews = {};
  List<dynamic> test1 = [];

  List<Map> wordCloud = [];

  WordCloudData wcdata = WordCloudData(data: [{'word': 'Loading...', 'value': 100},
    {'word': '', 'value': 60},]);


  Map<String, int> overallSentiment = {};

  List menu = [];

  double rating = 0.0;
  double totalSale = 0.0;

  int totalReviews = 0;
  int counter = 0;

  List timeOptions = ['Today', 'Yesterday', 'This Week', 'This Month', 'This Year', 'All Time'];
  String selectedTime = 'Today';

  List<VBarChartModel> bardata = [];
  List<VBarChartModel> menuRating = [];

  bool wordCloudGreaterThanOne = false;

  List categoryItems = [];
  String firstCategory = 'Loading...';

  String selectedFood = 'Default';


  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      menu = await getMenu();
      rating = await returnRating(selectedTime, selectedFood);
      totalReviews = await returnTotalReview(selectedTime, selectedFood);
      totalSale = await returnSale(selectedTime, selectedFood);
      overallSentiment = await returnSentiment(selectedTime, selectedFood);
      wordCloud = await returnWordCloud(selectedTime, selectedFood);
      bardata = await returnBarData(selectedTime, selectedFood);
      menuRating = await returnMenuRating(selectedTime, selectedFood);
      counter = await returnWordCloudCounter(selectedTime, selectedFood);
      categoryItems = await getCategory();
      firstCategory = categoryItems[0];


      if (mounted) {
        setState(() {
          reviews = reviews;
          menu = menu;
          rating = rating;
          totalSale = totalSale;
          overallSentiment = overallSentiment;
          wcdata = WordCloudData(data: wordCloud);
          wordCloudGreaterThanOne = hasValueGreaterThanOne(wcdata.data);
          print(wordCloudGreaterThanOne);
          bardata = bardata;
          counter= counter;
          categoryItems = categoryItems;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  bool hasValueGreaterThanOne(List<Map<dynamic,dynamic>> data) {
    for (var item in data) {
      if (item['value'] > 1) {
        return true;
      }
    }
    return false;
  }

  void updateCategory() async {
    try {
      menu = await getMenu();
      rating = await returnRating(selectedTime, selectedFood);
      totalReviews = await returnTotalReview(selectedTime, selectedFood);
      totalSale = await returnSale(selectedTime, selectedFood);
      overallSentiment = await returnSentiment(selectedTime, selectedFood);
      wordCloud = await returnWordCloud(selectedTime, selectedFood);
      bardata = await returnBarData(selectedTime, selectedFood);
      menuRating = await returnMenuRating(selectedTime, selectedFood);
      counter = await returnWordCloudCounter(selectedTime, selectedFood);
      categoryItems = await getCategory();


      if (mounted) {
        setState(() {
          reviews = reviews;
          menu = menu;
          rating = rating;
          totalSale = totalSale;
          overallSentiment = overallSentiment;
          wcdata = WordCloudData(data: wordCloud);
          wordCloudGreaterThanOne = hasValueGreaterThanOne(wcdata.data);
          print(wordCloudGreaterThanOne);
          bardata = bardata;
          counter= counter;
          categoryItems = categoryItems;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
                  value: selectedTime,
                  items: timeOptions.map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTime = value.toString();
                      updateCategory();
                    });
                  },
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                DropdownButton(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
                  value: firstCategory,
                  items: categoryItems.map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
                  onChanged: (value) {
                    setState(() {
                      firstCategory = value.toString();
                      selectedFood = firstCategory;
                      fetchData();
                    });
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.height * 0.06,
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
                              Text("KPIs",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: MediaQuery.of(context).size.height * 0.025,
                                ),
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
                              Text("Rating",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: MediaQuery.of(context).size.height * 0.025,
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                    ],
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.34,
                        height: MediaQuery.of(context).size.height * 0.34,
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
                              Text("Overall Sentiment",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: MediaQuery.of(context).size.height * 0.025,
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                height: MediaQuery.of(context).size.width * 0.15,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        value: overallSentiment['positive']?.toDouble(),
                                        color: Colors.green,
                                        title: 'Positive',
                                        radius: 50,
                                      ),
                                      PieChartSectionData(
                                        value: overallSentiment['negative']?.toDouble(),
                                        color: Colors.red,
                                        title: 'Negative',
                                        radius: 50,
                                      ),
                                      PieChartSectionData(
                                        value: overallSentiment['neutral']?.toDouble(),
                                        color: Colors.blue,
                                        title: 'Neutral',
                                        radius: 50,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.34,
                        height: MediaQuery.of(context).size.height * 0.34,
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
                              Text("Word Cloud",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: MediaQuery.of(context).size.height * 0.025,
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                              if (counter < 2 || wordCloudGreaterThanOne == false)
                                Column(
                                  children: [
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                                    Text("No data available"),
                                  ],
                                ),

                              if (counter > 1 && wordCloudGreaterThanOne == true)
                                WordCloudView(
                                  key: ValueKey(wcdata),
                                  data: wcdata,
                                  mapwidth: MediaQuery.of(context).size.width * 0.2,
                                  mapheight: MediaQuery.of(context).size.height * 0.2,
                                  mintextsize: MediaQuery.of(context).size.height * 0.01,
                                  maxtextsize: MediaQuery.of(context).size.height * 0.03,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.34,
                        height: MediaQuery.of(context).size.height * 0.34,
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
                              Text("Word Frequency",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: MediaQuery.of(context).size.height * 0.025,
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.25,
                                height: MediaQuery.of(context).size.height * 0.25,
                                child: SingleChildScrollView(
                                  child: VerticalBarchart(
                                    maxX: 55,
                                    data: bardata,
                                    showLegend: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.34,
                            height: MediaQuery.of(context).size.height * 0.34,
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
                                  Text("Rating by Menu",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: MediaQuery.of(context).size.height * 0.025,
                                    ),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.25,
                                    height: MediaQuery.of(context).size.height * 0.25,
                                    child: SingleChildScrollView(
                                      child: VerticalBarchart(
                                        maxX: 55,
                                        data: menuRating,
                                        showLegend: false,
                                        tooltipSize: MediaQuery.of(context).size.height * 0.1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]
        ),
      )
    );
  }
}
