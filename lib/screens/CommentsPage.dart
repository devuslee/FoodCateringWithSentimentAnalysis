import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableColor.dart';
import 'package:google_fonts/google_fonts.dart';

import '../reusableWidgets/reusableFunctions.dart';
import '../reusableWidgets/reusableWidgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage({super.key});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {


  Map<String, List<Map<String, dynamic>>> reviews = {};
  Map<String, List<Map<String, dynamic>>> allReviews = {};
  List menu = [];
  List reviewMenu = ['Loading...'];
  List category = [];
  List timeOptions = ['Today', 'Yesterday', 'This Week', 'This Month', 'This Year', 'All Time'];
  List sentimentOptions = ['All', 'Positive', 'Neutral', 'Negative'];

  String selectedTime = 'Today';
  String selectedSentiment = 'All';
  String selectedCategory = 'Loading...';
  String trueSelectedCategory = "All";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      loading = true;
      reviews = await returnTodayReviews();
      menu = await getMenu();
      category = await getCategory();
      allReviews = await returnAllReviews(selectedTime, trueSelectedCategory);


      if (mounted) {
        setState(() {
          reviews = reviews;
          reviewMenu = menu;
          allReviews = allReviews;
          menu = menu;
          category = category;
          menu.insert(0, "All");


          if (category.isNotEmpty) {
            selectedCategory = "All";
          }

          loading = false;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void updateCategories() async {
    try {
      loading = true;
      reviews = await returnTodayReviews();
      allReviews = await returnAllReviews(selectedTime, selectedCategory);


      if (mounted) {
        setState(() {
          reviews = reviews;
          reviewMenu = menu;
          allReviews = allReviews;

          loading = false;

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
                ReusableAppBar(title: "Comments", backButton: true),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.2,
                                  child: Text("Time:", style: GoogleFonts.lato(
                                      fontSize: MediaQuery.of(context).size.height * 0.025,
                                    color: selectedButtonColor,
                                      fontWeight: FontWeight.bold
                                  )),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.3,
                                  child: DropdownButton(
                                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
                                    value: selectedTime,
                                    items: timeOptions.map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedTime = value.toString();
                                        updateCategories();
                                      });
                                    },
                                    isExpanded: true,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.2,
                                  child: Text("Menu:", style: GoogleFonts.lato(
                                      fontSize: MediaQuery.of(context).size.height * 0.025,
                                    color: selectedButtonColor,
                                    fontWeight: FontWeight.bold
                                  )),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.3,
                                  child: DropdownButton(
                                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
                                    value: selectedCategory == "All" ? "All" : selectedCategory,
                                    items: menu.map((e) => DropdownMenuItem<String>(child: Text(e), value: e)).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCategory = value.toString();
                                        trueSelectedCategory = selectedCategory;
                                        updateCategories();
                                      });
                                    },
                                    isExpanded: true,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.2,
                                  child: Text("Type:", style: GoogleFonts.lato(
                                      fontSize: MediaQuery.of(context).size.height * 0.025,
                                      color: selectedButtonColor,
                                      fontWeight: FontWeight.bold
                                  )),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.3,
                                  child: DropdownButton(
                                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
                                    value: selectedSentiment,
                                    items: sentimentOptions.map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSentiment = value.toString();
                                        updateCategories();
                                      });
                                    },
                                    isExpanded: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                      child: Text(
                          "Showing $selectedCategory menu at $selectedTime with $selectedSentiment sentiment",
                          style: GoogleFonts.lato(
                              fontSize: MediaQuery.of(context).size.height * 0.015,
                              color: Colors.grey,
                          )
                      )
                  ),
                ),

                if (loading)
                  Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      CircularProgressIndicator(),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Text("Loading...", style: GoogleFonts.lato(
                          fontSize: MediaQuery.of(context).size.height * 0.02,
                          color: Colors.grey,

                      )),
                    ],
                  ),

                if (allReviews.isEmpty && !loading)
                  Column(
                    children: [
                      Icon(Icons.error, size: MediaQuery.of(context).size.height * 0.1, color: Colors.red),
                      Text("No Reviews Found", style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.02)),
                    ],
                  ),

                if (allReviews.isNotEmpty && !loading)
                for (var item in menu)
                  if (allReviews[item]?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,),
                    child: Column(
                      children: [
                        Text("$item", style: GoogleFonts.lato(
                            fontSize: MediaQuery.of(context).size.height * 0.03,
                            fontWeight: FontWeight.bold,
                            color: selectedButtonColor
                        )),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: allReviews[item]?.length ?? 0,
                          itemBuilder: (context, index) {
                            String comment = '';
                            double positive = (allReviews[item]?[index]['positive']?.toDouble() ?? 0.0);
                            double neutral = (allReviews[item]?[index]['neutral']?.toDouble() ?? 0.0);
                            double negative = (allReviews[item]?[index]['negative']?.toDouble() ?? 0.0);
                            double highest = max(positive, max(neutral, negative));
                            if (highest == positive) {
                              comment = 'Positive';
                            } else if (highest == neutral) {
                              comment = 'Neutral';
                            } else if (highest == negative) {
                              comment = 'Negative';
                            }

                            if (selectedSentiment == comment && selectedSentiment != "All" || selectedSentiment == "All") {
                              return Column(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(width: MediaQuery.of(context).size.width * 0.015),
                                                  Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            FutureBuilder(
                                                              future: getProfileImage(allReviews[item]?[index]['userID']),
                                                              builder: (context, snapshot) {
                                                                return CachedNetworkImage(
                                                                  imageUrl: snapshot.data.toString(),
                                                                  imageBuilder: (context, imageProvider) => Container(
                                                                    width: 50.0,
                                                                    height: 50.0,
                                                                    decoration: BoxDecoration(
                                                                      shape: BoxShape.circle,
                                                                      image: DecorationImage(
                                                                        image: imageProvider,
                                                                        fit: BoxFit.cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  placeholder: (context, url) => CircularProgressIndicator(),
                                                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                                                );
                                                              },
                                                            ),
                                                            SizedBox(width: MediaQuery.of(context).size.width * 0.015),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                FutureBuilder(
                                                                  future: getUsername(allReviews[item]?[index]['userID']),
                                                                  builder: (context, snapshot) {
                                                                    return Text(
                                                                        snapshot.data.toString(),
                                                                        style: GoogleFonts.lato(
                                                                          fontSize: MediaQuery.of(context).size.height * 0.025,
                                                                          fontWeight: FontWeight.bold,
                                                                        )
                                                                    );
                                                                  },
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(comment,
                                                                        style: GoogleFonts.lato(
                                                                            fontSize: MediaQuery.of(context).size.height * 0.02,
                                                                            color: comment == "Positive" ? Colors.green : comment == "Negative" ? Colors.red : Colors.yellow[800],
                                                                            fontWeight: FontWeight.bold
                                                                        )
                                                                    ),
                                                                    SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                                                                    Tooltip(
                                                                      message: "Positive: ${positive.toStringAsFixed(2)}\nNeutral: ${neutral.toStringAsFixed(2)}\nNegative: ${negative.toStringAsFixed(2)}",
                                                                      child: Icon(Icons.info, size: MediaQuery.of(context).size.height * 0.02,
                                                                        color: Colors.grey,),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                                        Row(
                                                          children: [
                                                            IgnorePointer(
                                                                ignoring: true,
                                                                child: RatingBar.builder(
                                                                  initialRating: allReviews[item]?[index]['rating'].toDouble() ?? 0.0,
                                                                  direction: Axis.horizontal,
                                                                  allowHalfRating: true,
                                                                  itemCount: 5,
                                                                  itemSize: MediaQuery.of(context).size.height * 0.025,
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
                                                            SizedBox(width: MediaQuery.of(context).size.width * 0.005),
                                                            Text(DaysFromTimeStamp(
                                                                allReviews[item]?[index]['createdAt']),
                                                                style: TextStyle(
                                                                    fontSize: MediaQuery.of(context).size.height * 0.02)
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          width: MediaQuery.of(context).size.width * 0.85,
                                                          child: Text(
                                                            allReviews[item]?[index]['comment'],
                                                            style: TextStyle(
                                                              fontSize: MediaQuery.of(context).size.height * 0.02,
                                                            ),
                                                            maxLines: null, // Allows the text to use as many lines as needed
                                                            overflow: TextOverflow.visible, // Ensures overflowed text is visible
                                                            softWrap: true, // Ensures text wraps to the next line
                                                          ),
                                                        ),
                                                      ]
                                                  )
                                                ],
                                              ),
                                            ]
                                        ),
                                      )
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                ],
                              );
                            } else {
                              return Container();
                            }
                          },
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
