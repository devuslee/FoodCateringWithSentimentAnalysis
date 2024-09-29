import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

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

  String selectedTime = 'Today';
  String selectedCategory = 'Loading...';
  String trueSelectedCategory = "Default";

  @override
  void initState() {
    super.initState();
    // fetchData();
  }

  void fetchData() async {
    try {
      reviews = await returnTodayReviews();
      allReviews = await returnAllReviews(selectedTime, trueSelectedCategory);
      menu = await getMenu();
      category = await getCategory();

      if (mounted) {
        setState(() {
          reviews = reviews;
          reviewMenu = menu;
          allReviews = allReviews;
          menu = menu;
          category = category;
          selectedCategory = category[0];
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void updateCategories() async {
    try {
      reviews = await returnTodayReviews();
      allReviews = await returnAllReviews(selectedTime, trueSelectedCategory);

      menu = await getMenu();
      category = await getCategory();

      if (mounted) {
        setState(() {
          reviews = reviews;
          reviewMenu = menu;
          allReviews = allReviews;
          menu = menu;
          category = category;
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
                ReusableAppBar(title: "Analysis", backButton: true),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text("Today's Reviews", style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.025, fontWeight: FontWeight.bold)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
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
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: DropdownButton(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
                          value: selectedCategory,
                          items: category.map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value.toString();
                              trueSelectedCategory = selectedCategory;
                              updateCategories();
                            });
                          },
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          setState(() {
                            reviewMenu = menu;
                          });
                        }
                    )
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                if (allReviews.isEmpty)
                  Column(
                    children: [
                      Icon(Icons.error, size: MediaQuery.of(context).size.height * 0.1, color: Colors.red),
                      Text("No Reviews Found", style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.02)),
                    ],
                  ),

                if (allReviews.isNotEmpty)
                for (var item in menu)
                  if (allReviews[item]?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                            Column(
                              children: [
                                Text("$item", style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.025, fontWeight: FontWeight.bold)),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                              ],
                            ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: allReviews[item]?.length ?? 0,
                          itemBuilder: (context, index) {
                            String comment = '';
                            double positive = allReviews[item]?[index]['positive'];
                            double neutral = allReviews[item]?[index]['neutral'];
                            double negative = allReviews[item]?[index]['negative'];
                            double highest = max(positive, max(neutral, negative));
                            if (highest == positive) {
                              comment = 'positive';
                            } else if (highest == neutral) {
                              comment = 'neutral';
                            } else if (highest == negative) {
                              comment = 'negative';
                            }
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
                                            SizedBox(width: MediaQuery.of(context).size.width * 0.005),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                FutureBuilder(
                                                  future: getUsername(allReviews[item]?[index]['userID']),
                                                  builder: (context, snapshot) {
                                                    return Text(
                                                        snapshot.data.toString(),
                                                        style: TextStyle(
                                                            fontSize: MediaQuery.of(context).size.height * 0.03,
                                                            fontWeight: FontWeight.bold
                                                        )
                                                    );
                                                  },
                                                ),
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
                                                Row(
                                                  children: [
                                                    Text(
                                                        "Overall Sentiment: ",
                                                        style: TextStyle(
                                                            fontSize: MediaQuery.of(context).size.height * 0.025,
                                                            color: Colors.grey
                                                        )
                                                    ),
                                                    Text("${comment}",
                                                        style: TextStyle(
                                                            fontSize: MediaQuery.of(context).size.height * 0.03,
                                                            color: comment == "positive" ? Colors.green : comment == "negative" ? Colors.red : Colors.yellow
                                                        )
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context).size.width * 0.9,
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
