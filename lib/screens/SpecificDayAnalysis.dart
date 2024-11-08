import 'package:flutter/material.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableWidgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableWidgets.dart';
import 'package:foodcateringwithsentimentanalysis/screens/SpecificDayAnalysis.dart';
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
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableWidgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableColor.dart';


class SpecificDayAnalysis extends StatefulWidget {
  const SpecificDayAnalysis({super.key});

  @override
  State<SpecificDayAnalysis> createState() => _SpecificDayAnalysisState();
}

class _SpecificDayAnalysisState extends State<SpecificDayAnalysis> {
  String selectedDateTime = DateTime.now().toString().split(" ")[0];

  Map<String, List<Map<String, dynamic>>> reviews = {};
  List<dynamic> test1 = [];

  List<Map> wordCloud = [];

  List<FlSpot> linegraphSales = [];
  List<ScatterSpot> scatterData = [];

  DateTime startDate = DateTime.now();
  DateTime previousWeek = DateTime.now();
  DateTime thisWeek = DateTime.now();

  WordCloudData wcdata = WordCloudData(data: [{'word': 'Loading...', 'value': 100},
    {'word': '', 'value': 60},]);


  Map<String, double> overallSentiment = {};
  Map<String, Map<String, double>> sentimentRating = {};
  Map<String, List<Map<String, dynamic>>> allReviews = {};

  List menu = [];

  double rating = 0.0;
  num totalSale = 0.0;

  int totalReviews = 0;
  int counter = 0;

  List timeOptions = ['Today', 'Yesterday', 'This Week', 'This Month', 'This Year', 'All Time'];
  List lineGraphOptions = ['This Week', "Previous Week"];

  String selectedLineGraphOption = "This Week";
  String selectedScatterPlotOption = "This Week";
  String selectedTime = DateTime.now().toString().split(" ")[0];


  List<VBarChartModel> bardata = [];
  List<VBarChartModel> menuRating = [];

  bool wordCloudGreaterThanOne = false;

  List categoryItems = [];
  String firstCategory = 'Loading...';

  String selectedFood = 'Default';

  int positiveSentiment = 0;
  int negativeSentiment = 0;
  int neutralSentiment = 0;


  bool sentimentByMenuHasData = false;
  bool loading = true;
  double bardataMax = 0.0;

  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      loading = true;
      menuRating = [];

      menu = await getMenu();
      rating = await returnSpecificDayRating(selectedTime, selectedFood);
      totalReviews = await returnSpecificDayTotalReview(selectedTime, selectedFood);
      totalSale = await returnSpecificDaySale(selectedTime, selectedFood);

      overallSentiment = await returnSpecificDaySentiment(selectedTime, selectedFood);

      wordCloud = await returnSpecificDayWordCloud(selectedTime, selectedFood);
      counter = await returnSpecificDayWordCloudCounter(selectedTime, selectedFood);
      bardata = await returnSpecificDayWordFrequency(selectedTime, selectedFood);
      bardataMax = await returnSpecificDayMaxXWordFrequency(selectedTime, selectedFood);

      menuRating = await returnSpecificDayMenuRating(selectedTime, selectedFood);

      sentimentRating = await returnSpecificDaySentimentRating(selectedTime, selectedFood);
      scatterData = await returnSpecificDayScatterData(selectedTime, selectedFood);


      double positive = overallSentiment['positive']?.toDouble() ?? 0;
      double negative = overallSentiment['negative']?.toDouble() ?? 0;
      double neutral = overallSentiment['neutral']?.toDouble() ?? 0;

      double total = positive + negative + neutral;

      if (total > 0) {
        positiveSentiment = ((positive / total) * 100).ceil();
        negativeSentiment = ((negative / total) * 100).ceil();
        neutralSentiment = ((neutral / total) * 100).ceil();
      } else {
        positiveSentiment = 0;
        negativeSentiment = 0;
        neutralSentiment = 0;
      }


      if (mounted) {
        setState(() {
          rating = rating;
          wcdata = WordCloudData(data: wordCloud);
          wordCloudGreaterThanOne = hasValueGreaterThanOne(wcdata.data);
          loading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ReusableAppBar(title: "Analysis by Day", backButton: true),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${DayMonthYearFormatter(selectedTime)} '),
                IconButton(
                    onPressed: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.parse(selectedDateTime),
                        firstDate: DateTime(2021),
                        lastDate: DateTime(2025),
                      );

                      if (date != null) {
                        selectedTime = date.toString().split(" ")[0];
                        setState(() {
                          fetchData();
                        });
                      }

                    },
                    icon: Icon(Icons.calendar_today)
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: 8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
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
                                style: GoogleFonts.lato(
                                  fontSize: MediaQuery.of(context).size.width * 0.05, // Adjust font size
                                  fontWeight: FontWeight.bold, // Adjust font weight
                                  color: selectedButtonColor, // Adjust text color
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.height * 0.11,
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
                        child: Column(
                          children: [
                            Text("Rating",
                              style: GoogleFonts.lato(
                                fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                                fontWeight: FontWeight.bold, // Adjust font weight
                                color: selectedButtonColor, // Adjust text color
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                            IgnorePointer(
                                ignoring: true,
                                child: RatingBar.builder(
                                  initialRating: rating,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: MediaQuery.of(context).size.height * 0.02,
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
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.height * 0.11,
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
                        child: Column(
                          children: [
                            Text("Reviews",
                              style: GoogleFonts.lato(
                                fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                                fontWeight: FontWeight.bold, // Adjust font weight
                                color: selectedButtonColor, // Adjust text color
                              ),
                            ),
                            Text("${totalReviews}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: MediaQuery.of(context).size.height * 0.025,
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.225,
                              height: MediaQuery.of(context).size.height * 0.035,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 0), // Remove horizontal padding
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CommentsPage()),
                                  );
                                },
                                child: Text("Comments",
                                  style: GoogleFonts.lato(
                                    fontSize: MediaQuery.of(context).size.width * 0.03,
                                    fontWeight: FontWeight.bold,
                                    color: selectedButtonColor,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.height * 0.11,
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
                              Text("Sales",
                                style: GoogleFonts.lato(
                                  fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                                  fontWeight: FontWeight.bold, // Adjust font weight
                                  color: selectedButtonColor, // Adjust text color
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                              Text("RM${totalSale}",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: MediaQuery.of(context).size.height * 0.02,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.67,
                        height: MediaQuery.of(context).size.height * 0.42,
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
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Spacer(),
                                  Spacer(),
                                  Text("Overall Sentiment",
                                    style: GoogleFonts.lato(
                                      fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                                      fontWeight: FontWeight.bold, // Adjust font weight
                                      color: selectedButtonColor, // Adjust text color
                                    ),
                                  ),
                                  Spacer(),
                                  Tooltip(
                                    message: "Automatically analyses comments and gives a sentiment score \n"
                                        "Positive: ${positiveSentiment}% \n"
                                        "Negative: ${negativeSentiment}% \n"
                                        "Neutral: ${neutralSentiment}%",
                                    child: Icon(Icons.info_outline,
                                      color: Colors.grey,
                                      size: MediaQuery.of(context).size.width * 0.05,),
                                  )
                                ],
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                              if (loading == true)
                                Column(
                                  children: [
                                    Text("Loading Data..."),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                    CircularProgressIndicator(),
                                  ],
                                ),

                              if (loading == false && overallSentiment['positive'] == 0 && overallSentiment['negative'] == 0 && overallSentiment['neutral'] == 0)
                                Column(
                                  children: [
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                    Image.asset('assets/nodata.png'),
                                    Text("No data available", style: GoogleFonts.lato(
                                      fontSize: MediaQuery.of(context).size.width * 0.04,
                                      color: Colors.grey,
                                    ),),
                                  ],
                                ),

                              if (loading == false && overallSentiment['positive'] != 0 && overallSentiment['negative'] != 0 && overallSentiment['neutral'] != 0 && overallSentiment.isNotEmpty)
                                Column(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.45,
                                      height: MediaQuery.of(context).size.width * 0.45,
                                      child: PieChart(
                                        PieChartData(
                                          sections: [
                                            PieChartSectionData(
                                              value: overallSentiment['positive']?.toDouble(),
                                              color: Colors.green,
                                              title: positiveSentiment == 0 ? "Wait" : "${positiveSentiment}%" ,
                                              radius: 50,
                                            ),
                                            PieChartSectionData(
                                              value: overallSentiment['negative']?.toDouble(),
                                              color: Colors.red,
                                              title: negativeSentiment == 0 ? "Wait" : "${negativeSentiment}%" ,
                                              radius: 50,
                                            ),
                                            PieChartSectionData(
                                              value: overallSentiment['neutral']?.toDouble(),
                                              color: Colors.blue,
                                              title: neutralSentiment == 0 ? "Wait" : "${neutralSentiment}%",
                                              radius: 50,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Spacer(),
                                        Container(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Container(
                                                      width: 16,
                                                      height: 16,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.rectangle,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 4,
                                                    ),
                                                    Text(
                                                      "Positive",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.green,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Container(
                                                      width: 16,
                                                      height: 16,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.rectangle,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 4,
                                                    ),
                                                    Text(
                                                      "Negative",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.red,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Container(
                                                      width: 16,
                                                      height: 16,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.rectangle,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 4,
                                                    ),
                                                    Text(
                                                      "Neutral",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.blue,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: 8.0,
              ),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.46,
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
                          Row(
                            children: [
                              Spacer(),
                              Spacer(),
                              Text("Sentiment By Menu",
                                style: GoogleFonts.lato(
                                  fontSize: MediaQuery.of(context).size.width * 0.035, // Adjust font size
                                  fontWeight: FontWeight.bold, // Adjust font weight
                                  color: selectedButtonColor, // Adjust text color
                                ),
                              ),
                              Spacer(),
                              Tooltip(
                                message: "Overall Sentiment for each menu",
                                child: Icon(Icons.info_outline,
                                  color: Colors.grey,
                                  size: MediaQuery.of(context).size.width * 0.05,
                                ),
                              )
                            ],
                          ),

                          if (loading == true)
                            Column(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                Text("Loading Data..."),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                CircularProgressIndicator(),
                              ],
                            ),

                          if (sentimentRating.isNotEmpty && loading == false)
                            SingleChildScrollView(
                              child: Column(
                                children: menu.map((item) {
                                  String comment = '';
                                  double? positive = sentimentRating[item]?['positive'];
                                  double? neutral = sentimentRating[item]?['neutral'];
                                  double? negative = sentimentRating[item]?['negative'];

                                  // Ensure positive, neutral, and negative are not null before comparison
                                  double highest = [positive ?? 0, neutral ?? 0, negative ?? 0].reduce(max);

                                  if (highest == 0) {
                                    return SizedBox(); // Skip the widget if no sentiment score is available
                                  } else {
                                    // Determine the sentiment type
                                    if (highest == positive) {
                                      comment = 'positive';
                                    } else if (highest == neutral) {
                                      comment = 'neutral';
                                    } else if (highest == negative) {
                                      comment = 'negative';
                                    }

                                    sentimentByMenuHasData = true;

                                    // Get screen dimensions once for reuse
                                    final screenHeight = MediaQuery.of(context).size.height;
                                    final screenWidth = MediaQuery.of(context).size.width;

                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "$item :",
                                          style: GoogleFonts.lato(
                                            fontSize: screenHeight * 0.02,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        Text(
                                          "$comment",
                                          style: TextStyle(
                                            color: comment == "positive"
                                                ? Colors.green
                                                : comment == "neutral"
                                                ? Colors.yellow[800]
                                                : Colors.red,
                                            fontSize: screenHeight * 0.02,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                }).toList(),
                              ),
                            ),

                          if (sentimentByMenuHasData == false && sentimentRating.isNotEmpty && loading == false)
                            Column(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                Image.asset('assets/nodata.png'),
                                Text("No data available", style: GoogleFonts.lato(
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                  color: Colors.grey,
                                ),),
                              ],
                            ),

                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.46,
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
                          Row(
                            children: [
                              Spacer(),
                              Spacer(),
                              Text("Rating by Menu",
                                style: GoogleFonts.lato(
                                  fontSize: MediaQuery.of(context).size.width * 0.035, // Adjust font size
                                  fontWeight: FontWeight.bold, // Adjust font weight
                                  color: selectedButtonColor, // Adjust text color
                                ),
                              ),
                              Spacer(),
                              Tooltip(
                                message: "Average rating for each menu",
                                child: Icon(Icons.info_outline,
                                  color: Colors.grey,
                                  size: MediaQuery.of(context).size.width * 0.05,),
                              )
                            ],
                          ),

                          if (menuRating.isEmpty && loading == true)
                            Column(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                Text("Loading Data..."),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                CircularProgressIndicator(),
                              ],
                            ),

                          if (menuRating.isEmpty && loading == false)
                            Column(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                Image.asset('assets/nodata.png'),
                                Text("No data available", style: GoogleFonts.lato(
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                  color: Colors.grey,
                                ),),
                              ],
                            ),

                          if (menuRating.isNotEmpty  && loading == false)
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.95,
                              height: MediaQuery.of(context).size.height * 0.25,
                              child: SingleChildScrollView(
                                child: VerticalBarchart(
                                  maxX: 5,
                                  data: menuRating,
                                  showLegend: false,
                                  tooltipSize: MediaQuery.of(context).size.height * 0.05,
                                  labelSizeFactor: 0.6,
                                  labelColor: Colors.black,
                                ),
                              ),
                            ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: 8.0,
              ),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.46,
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
                          Row(
                            children: [
                              Spacer(),
                              Spacer(),
                              Text("Word Cloud",
                                style: GoogleFonts.lato(
                                  fontSize: MediaQuery.of(context).size.width * 0.035, // Adjust font size
                                  fontWeight: FontWeight.bold, // Adjust font weight
                                  color: selectedButtonColor, // Adjust text color
                                ),
                              ),
                              Spacer(),
                              Tooltip(
                                message: "Overview of all the words used in the comments",
                                child: Icon(Icons.info_outline,
                                  color: Colors.grey,
                                  size: MediaQuery.of(context).size.width * 0.05,),
                              ),
                            ],
                          ),

                          if (loading == true)
                            Column(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                Text("Loading Data..."),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                CircularProgressIndicator(),
                              ],
                            ),

                          if (counter < 2 && wordCloudGreaterThanOne == false && loading == false)
                            Column(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                Image.asset('assets/nodata.png'),
                                Text("No data available", style: GoogleFonts.lato(
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                  color: Colors.grey,
                                ),),
                              ],
                            ),

                          if (counter > 1 && wordCloudGreaterThanOne == true && loading == false)
                            Column(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                WordCloudView(
                                  key: ValueKey(wcdata),
                                  data: wcdata,
                                  colorlist: [Colors.black],
                                  mapwidth: MediaQuery.of(context).size.width * 0.2,
                                  mapheight: MediaQuery.of(context).size.height * 0.2,
                                  mintextsize: MediaQuery.of(context).size.height * 0.015,
                                  maxtextsize: MediaQuery.of(context).size.height * 0.045,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.46,
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
                          Row(
                            children: [
                              Spacer(),
                              Spacer(),
                              Text("Word Frequency",
                                style: GoogleFonts.lato(
                                  fontSize: MediaQuery.of(context).size.width * 0.035, // Adjust font size
                                  fontWeight: FontWeight.bold, // Adjust font weight
                                  color: selectedButtonColor, // Adjust text color
                                ),
                              ),
                              Spacer(),
                              Tooltip(
                                message: "How frequent a word appears in the comments",
                                child: Icon(Icons.info_outline,
                                  color: Colors.grey,
                                  size: MediaQuery.of(context).size.width * 0.05,),
                              ),
                            ],
                          ),
                          if (loading == true)
                            Column(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                Text("Loading Data..."),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                CircularProgressIndicator(),
                              ],
                            ),

                          if (bardata.isEmpty && loading == false)
                            Column(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                Image.asset('assets/nodata.png'),
                                Text("No data available", style: GoogleFonts.lato(
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                  color: Colors.grey,
                                ),),
                              ],
                            ),

                          if (bardata.isNotEmpty && loading == false)
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.95,
                              height: MediaQuery.of(context).size.height * 0.25,
                              child: SingleChildScrollView(
                                child: VerticalBarchart(
                                  maxX: bardataMax * 1.1,
                                  data: bardata,
                                  showLegend: false,
                                  tooltipSize: MediaQuery.of(context).size.height * 0.05,
                                  labelSizeFactor: 0.5,
                                  labelColor: Colors.black,
                                ),
                              ),
                            ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.94,
              height: MediaQuery.of(context).size.height * 0.445,
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
                padding: const EdgeInsets.only(
                  top: 8.0,
                  right: 8.0,
                  bottom: 0,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        Spacer(),
                        Text("Rating vs Sentiment",
                          style: GoogleFonts.lato(
                            fontSize: MediaQuery.of(context).size.width * 0.05, // Adjust font size
                            fontWeight: FontWeight.bold, // Adjust font weight
                            color: selectedButtonColor, // Adjust text color
                          ),
                        ),
                        Spacer(),
                        Tooltip(
                          message: "Shows the rating of each day VS the analysed sentiment score",
                          child: Icon(Icons.info_outline,
                            color: Colors.grey,
                            size: MediaQuery.of(context).size.width * 0.05,),
                        )
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                    if (loading == true)
                      Column(
                        children: [
                          Text("Loading Data..."),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                          CircularProgressIndicator(),
                        ],
                      ),

                    if (scatterData.isEmpty && loading == false)
                      Column(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                          Image.asset('assets/nodata.png'),
                          Text("No data available", style: GoogleFonts.lato(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            color: Colors.grey,
                          ),),
                        ],
                      ),

                    if (scatterData.isNotEmpty && loading == false)
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.33,
                          child: ScatterChart(
                            ScatterChartData(
                              scatterSpots: scatterData,
                              minX: 0,
                              maxX: 5,
                              minY: 0,
                              maxY: 5,
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                    axisNameWidget: Row(
                                      children: [
                                        Spacer(),
                                        Spacer(),
                                        Text('Sentiment Score',
                                          style: GoogleFonts.lato(
                                            fontSize: MediaQuery.of(context).size.width * 0.045,
                                          ),),
                                        Spacer(),
                                      ],
                                    ),
                                    axisNameSize: MediaQuery.of(context).size.width * 0.075,
                                    sideTitles: SideTitles(showTitles: true,
                                      reservedSize: MediaQuery.of(context).size.width * 0.1,
                                    )
                                ),
                                bottomTitles: AxisTitles(
                                  axisNameSize: MediaQuery.of(context).size.width * 0.06,
                                  axisNameWidget: Row(
                                    children: [
                                      Spacer(),
                                      Spacer(),
                                      Text(
                                        'Rating',
                                        style: GoogleFonts.lato(
                                          fontSize: MediaQuery.of(context).size.width * 0.045,
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                  sideTitles: SideTitles(showTitles: true,
                                      interval: 1,
                                      reservedSize: MediaQuery.of(context).size.width * 0.1),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          ],
        ),
      ),
    );
  }
}

