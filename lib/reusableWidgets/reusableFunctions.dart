import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:huggingface_dart/huggingface_dart.dart';
import 'package:intl/intl.dart';
import 'package:vertical_barchart/vertical-barchartmodel.dart';
import 'package:http/http.dart' as http;
import '../screens/AnalysisPage.dart';
import '../screens/LoginPage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
HfInference hfInference = HfInference('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');
String? currentUser = FirebaseAuth.instance.currentUser!.uid;


Future<List<Map<String, dynamic>>> returnAllOrders(String selectedTime) async {
  List<Map<String, dynamic>> orders = [];
  print(selectedTime.split(' ')[0]);

  //actual code
  final orderRef = FirebaseFirestore.instance
      .collection('admin')
      .doc('orders')
      .collection(selectedTime.split(' ')[0]);


  // final orderRef = FirebaseFirestore.instance
  //     .collection('admin')
  //     .doc('orders')
  //     .collection("2024-08-09");


  await orderRef.get().then((querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      orders.add(doc.data());
    });
  });

  return orders;
}

Future<Map<String, List<Map<String, dynamic>>>> returnTodayReviews() async {
  Map<String, List<Map<String, dynamic>>> reviewsByMenu = {};
  List menu = await getMenu();


  for (var item in menu) {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(item);

    //correct code
    await reviewRef.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc.data()?['createdAt'].toString().split(' ')[0] == DateTime.now().toString().split(' ')[0]) {
          if (!reviewsByMenu.containsKey(item)) {
            reviewsByMenu[item] = [];
          }
          reviewsByMenu[item]?.add(doc.data());
        }
      });
    });

  }

  return reviewsByMenu;
}

Future<Map<String, List<Map<String, dynamic>>>> returnAllReviews(String timeRange, String selectedCategory) async {
  Map<String, List<Map<String, dynamic>>> reviewsByMenu = {};
  List menu = await getMenu();

  DateTime startDate;

  if (timeRange == 'Today') {
    startDate = DateTime.now();
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
  } else if (timeRange == 'Yesterday') {
    startDate = DateTime.now().subtract(Duration(days: 1));
  } else if (timeRange == 'This Week') {
    startDate = DateTime.now().subtract(Duration(days: 7));
  } else if (timeRange == 'This Month') {
    startDate = DateTime(DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);
  } else if (timeRange == 'This Year') {
    startDate = DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
  } else if (timeRange == 'All Time') {
    //set it to a date that is way before the app is created
    //doesnt matter what it is
    startDate = DateTime(2021, 1, 1);
  } else {
    startDate = DateTime.now();
  }


  if (selectedCategory == "All") {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      await reviewRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          if (doc.data()?['createdAt'] != null) {
            DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
            if (createdAt.isAfter(startDate) && createdAt.isBefore(DateTime.now())) {
              if (!reviewsByMenu.containsKey(item)) {
                reviewsByMenu[item] = [];
              }
              reviewsByMenu[item]?.add(doc.data());
            }
          } else {
            print("Null createdAt for document: ${doc.id}");
          }
        });
      });
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedCategory);

    await reviewRef.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
        if (createdAt.isAfter(startDate) && createdAt.isBefore(DateTime.now())) {
          if (!reviewsByMenu.containsKey(selectedCategory)) {
            reviewsByMenu[selectedCategory] = [];
          }
          reviewsByMenu[selectedCategory]?.add(doc.data());
        }
      });
    });
  }

  return reviewsByMenu;
}


Future<double> returnRating(String timeRange, String selectedFood) async {
  double totalRating = 0;
  double counter = 0;
  double averageRating = 0;
  List menu = await getMenu();

  DateTime startDate;

  if (timeRange == 'Today') {
    startDate = DateTime.now();
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
  } else if (timeRange == 'Yesterday') {
    startDate = DateTime.now().subtract(Duration(days: 1));
  } else if (timeRange == 'This Week') {
    startDate = DateTime.now().subtract(Duration(days: 7));
  } else if (timeRange == 'This Month') {
    startDate = DateTime(DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);
  } else if (timeRange == 'This Year') {
    startDate = DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
  } else if (timeRange == 'All Time') {
    //set it to a date that is way before the app is created
    //doesnt matter what it is
    startDate = DateTime(2021, 1, 1);
  } else {
    startDate = DateTime.now();
  }

  if (selectedFood == 'Default') {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      await reviewRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
          if (createdAt.isAfter(startDate) &&
              createdAt.isBefore(DateTime.now())) {
            totalRating = totalRating + doc.data()?['rating'];
            counter = counter + 1;
          }
        });
      });
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    await reviewRef.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
        if (createdAt.isAfter(startDate) && createdAt.isBefore(DateTime.now())) {
          totalRating = totalRating + doc.data()?['rating'];
          counter = counter + 1;
        }
      });
    });
  }

  if (counter != 0) {
    averageRating = totalRating / counter;
  }

  return double.parse(averageRating.toStringAsFixed(2));
}

Future<double> returnSpecificDayRating(String specificDay, String selectedFood) async {
  double totalRating = 0;
  double counter = 0;
  double averageRating = 0;
  List menu = await getMenu();

  DateTime startDate;

  if (selectedFood == 'Default') {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      await reviewRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
          if (createdAt == specificDay) {
            totalRating = totalRating + doc.data()?['rating'];
            counter = counter + 1;
          }
        });
      });
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    await reviewRef.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
        if (createdAt == specificDay) {
          totalRating = totalRating + doc.data()?['rating'];
          counter = counter + 1;
        }
      });
    });
  }

  if (counter != 0) {
    averageRating = totalRating / counter;
  }

  return double.parse(averageRating.toStringAsFixed(2));
}

Future<int> returnTotalReview(String timeRange, String selectedFood) async {
  int totalReviews = 0;
  List menu = await getMenu();

  DateTime startDate;

  if (timeRange == 'Today') {
    startDate = DateTime.now();
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
  } else if (timeRange == 'Yesterday') {
    startDate = DateTime.now().subtract(Duration(days: 1));
  } else if (timeRange == 'This Week') {
    startDate = DateTime.now().subtract(Duration(days: 7));
  } else if (timeRange == 'This Month') {
    startDate = DateTime(DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);
  } else if (timeRange == 'This Year') {
    startDate = DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
  } else if (timeRange == 'All Time') {
    //set it to a date that is way before the app is created
    //doesnt matter what it is
    startDate = DateTime(2021, 1, 1);
  } else {
    startDate = DateTime.now();
  }

  if (selectedFood == 'Default') {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      await reviewRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
          if (createdAt.isAfter(startDate) &&
              createdAt.isBefore(DateTime.now())) {
            totalReviews = totalReviews + 1;
          }
        });
      });
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    await reviewRef.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
        if (createdAt.isAfter(startDate) && createdAt.isBefore(DateTime.now())) {
          totalReviews = totalReviews + 1;
        }
      });
    });
  }


  return totalReviews;
}

Future<int> returnSpecificDayTotalReview(String specificDay, String selectedFood) async {
  int totalReviews = 0;
  List menu = await getMenu();

  DateTime startDate;

  if (selectedFood == 'Default') {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      await reviewRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
          if (createdAt == specificDay) {
            totalReviews = totalReviews + 1;
          }
        });
      });
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    await reviewRef.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
        if (createdAt == specificDay) {
          totalReviews = totalReviews + 1;
        }
      });
    });
  }


  return totalReviews;
}

Future<String> returnCategorywithName(String name) async {

  final menuCollectionRef = FirebaseFirestore.instance.collection('menu');

  try {
    final menuSnapshot = await menuCollectionRef.get();
    String category = '';

    for (var doc in menuSnapshot.docs) {
      final docData = doc.data() as Map<String, dynamic>;
      if (doc.data()?['name'] == name) {
        category = doc.data()?['category'];
      }
    }

    return category;
  } catch (e) {
    print('Failed to get category: $e');
    return '';
  }
}



Future<double> returnSale(String timeRange, String selectedFood) async {
  double totalSale = 0;

  int dayGap = 0;
  DateTime startDate;

  if (timeRange == 'Today') {
    startDate = DateTime.now();
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
    dayGap = 1;
  } else if (timeRange == 'Yesterday') {
    startDate = DateTime.now().subtract(Duration(days: 1));
    dayGap = 2;
  } else if (timeRange == 'This Week') {
    startDate = DateTime.now().subtract(Duration(days: 7));
    dayGap = 7;
  } else if (timeRange == 'This Month') {
    startDate = DateTime(DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);
    dayGap = 30;
  } else if (timeRange == 'This Year') {
    startDate = DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
    dayGap = 365;
  } else if (timeRange == 'All Time') {
    //set it to a date that is way before the app is created
    //doesnt matter what it is
    startDate = DateTime(2021, 1, 1);
    dayGap = 365;
  } else {
    startDate = DateTime.now();
  }

  if (selectedFood == 'Default') {
    for (var i = 0; i < dayGap; i++) {
      final orderRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('orders')
          .collection(
          DateTime.now().subtract(Duration(days: i)).toString().split(' ')[0]);

      await orderRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          var total = doc.data()['total'];
          if (total != null && total is num) { // Check for null and type
            totalSale += total;
          }
        });
      });
    }
  } else {
    for (var i = 0; i < dayGap; i++) {
      final orderRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('orders')
          .collection(
          DateTime.now().subtract(Duration(days: i)).toString().split(' ')[0]);

      await orderRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          for (var item in doc.data()['orderHistory']) {
            String category = await returnCategorywithName(item['name']);
            if (category == selectedFood) {
              var total = doc.data()['total'];
              if (total != null && total is num) { // Check for null and type
                totalSale += total;
              }
            }
          }
        });
      });
    }
  }

  return totalSale;
}

Future<double> returnSpecificDaySale(String specificDay, String selectedFood) async {
  double totalSale = 0;

  if (selectedFood == 'Default') {
      final orderRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('orders')
          .collection(specificDay);

      await orderRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          var total = doc.data()['total'];
          if (total != null && total is num) { // Check for null and type
            totalSale += total;
          }
        });
      });
  } else {
      final orderRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('orders')
          .collection(specificDay);

      await orderRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          for (var item in doc.data()['orderHistory']) {
            String category = await returnCategorywithName(item['name']);
            if (category == selectedFood) {
              var total = doc.data()['total'];
              if (total != null && total is num) { // Check for null and type
                totalSale += total;
              }
            }
          }
        });
      });
  }

  return totalSale;
}


Future<List<FlSpot>> returnLineGraphSales(String timeRange, String selectedFood) async {
  List<FlSpot> salesByDay = [];
  double totalSale = 0;

  int dayGap = 0;
  DateTime startDate = DateTime.now();

  if (timeRange == 'This Week') {
    while (startDate.weekday != 1) {
      startDate = startDate.subtract(Duration(days: 1));
    }
    dayGap = 7;
  } else if (timeRange == 'Previous Week') {
    while (startDate.weekday != 1) {
      startDate = startDate.subtract(Duration(days: 1));
    }
    startDate = startDate.subtract(Duration(days: 7));
    dayGap = 7;
  }

  if (selectedFood == 'Default') {
    for (var i = 0; i < dayGap; i++) {
      final orderRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('orders')
          .collection(startDate.add(Duration(days: i)).toString().split(' ')[0]);

      await orderRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          var total = doc.data()['total'];
          if (total != null && total is num) { // Check for null and type
            totalSale += total;
          }
        });
      });

      salesByDay.add(FlSpot(i.toDouble(), totalSale)); // Convert i to double here
      totalSale = 0;
    }
  } else {
    for (var i = 0; i < dayGap; i++) {
      final orderRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('orders')
          .collection(startDate.add(Duration(days: i)).toString().split(' ')[0]);

      await orderRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          for (var item in doc.data()['orderHistory']) {
            String category = await returnCategorywithName(item['name']);
            if (category == selectedFood) {
              var total = doc.data()['total'];
              if (total != null && total is num) { // Check for null and type
                totalSale += total;
              }
            }
          }
        });
      });

      salesByDay.add(FlSpot(i.toDouble(), totalSale)); // Convert i to double here
      totalSale = 0;
    }
  }

  return salesByDay;
}

Future<double> returnMaxYLineGraphSales(String timeRange, String selectedFood) async {
  double highest = 0;
  double totalSale = 0;

  int dayGap = 0;
  DateTime startDate = DateTime.now();

  if (timeRange == 'This Week') {
    while (startDate.weekday != 1) {
      startDate = startDate.subtract(Duration(days: 1));
    }
    dayGap = 7;
  } else if (timeRange == 'Previous Week') {
    while (startDate.weekday != 1) {
      startDate = startDate.subtract(Duration(days: 1));
    }
    startDate = startDate.subtract(Duration(days: 7));
    dayGap = 7;
  }

  if (selectedFood == 'Default') {
    for (var i = 0; i < dayGap; i++) {
      final orderRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('orders')
          .collection(startDate.add(Duration(days: i)).toString().split(' ')[0]);

      await orderRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          var total = doc.data()['total'];
          if (total != null && total is num) { // Check for null and type
            totalSale += total;
          }
        });
      });

      if (totalSale > highest) {
        highest = totalSale;
      }
      totalSale = 0;
    }
  } else {
    for (var i = 0; i < dayGap; i++) {
      final orderRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('orders')
          .collection(startDate.add(Duration(days: i)).toString().split(' ')[0]);

      await orderRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          for (var item in doc.data()['orderHistory']) {
            String category = await returnCategorywithName(item['name']);
            if (category == selectedFood) {
              var total = doc.data()['total'];
              if (total != null && total is num) { // Check for null and type
                totalSale += total;
              }
            }
          }
        });
      });

      if (totalSale > highest) {
        highest = totalSale;
      }
      totalSale = 0;
    }
  }
  //add more if else statements
  if (highest < 100) {
    highest = (highest / 10).ceil() * 10;
  } else if (highest > 100 && highest < 1000) {
    highest = (highest / 100).ceil() * 100;
  } else if (highest > 1000 && highest < 10000) {
    highest = (highest / 1000).ceil() * 1000;
  } else if (highest > 10000 && highest < 100000) {
    highest = (highest / 10000).ceil() * 10000;
  }


  return highest;
}


Future<List<ScatterSpot>> returnScatterData(String timeRange, String selectedFood) async {
  List<ScatterSpot> scatterData = [];
  double overallSentimentScore = 0;
  double rating = 0;

  double onestarRating = 0;
  double onestarRatingCount = 0;

  double twostarRating = 0;
  double twostarRatingCount = 0;

  double threestarRating = 0;
  double threestarRatingCount = 0;

  double fourstarRating = 0;
  double fourstarRatingCount = 0;

  double fivestarRating = 0;
  double fivestarRatingCount = 0;

  double totalCount = 0;

  List menu = await getMenu();

  int dayGap = 0;
  DateTime startDate = DateTime.now();

  if (timeRange == 'Today') {
    startDate = DateTime.now();
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
    dayGap = 1;
  } else if (timeRange == 'Yesterday') {
    startDate = DateTime.now().subtract(Duration(days: 1));
    dayGap = 2;
  } else if (timeRange == 'This Week') {
    startDate = DateTime.now().subtract(Duration(days: 7));
    dayGap = 7;
  } else if (timeRange == 'This Month') {
    startDate = DateTime(DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);
    dayGap = 30;
  } else if (timeRange == 'This Year') {
    startDate = DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
    dayGap = 365;
  } else if (timeRange == 'All Time') {
    //set it to a date that is way before the app is created
    //doesnt matter what it is
    startDate = DateTime(2021, 1, 1);
    dayGap = 365;
  } else {
    startDate = DateTime.now();
  }

  if (selectedFood == 'Default') {
    for (var item in menu) {
      final orderRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      await orderRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          double positive = (doc.data()['positive'] as num).toDouble();
          double neutral = (doc.data()['neutral'] as num).toDouble();
          double negative = (doc.data()['negative'] as num).toDouble();

          overallSentimentScore = (positive * 1) + (neutral * 0.6) + (negative * 0.2);
          DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
          if (createdAt.isAfter(startDate) &&
              createdAt.isBefore(DateTime.now())) {
            rating = (doc.data()['rating'] as num).toDouble();

            if (rating == 1) {
              onestarRating += overallSentimentScore;
              onestarRatingCount += 1;
            } else if (rating == 2) {
              twostarRating += overallSentimentScore;
              twostarRatingCount += 1;
            } else if (rating == 3) {
              threestarRating += overallSentimentScore;
              threestarRatingCount += 1;
            } else if (rating == 4) {
              fourstarRating += overallSentimentScore;
              fourstarRatingCount += 1;
            } else if (rating == 5) {
              fivestarRating += overallSentimentScore;
              fivestarRatingCount += 1;
            } else {
              print('rating not found');
            }
          }
        });
      });
    }
  } else {
    for (var i = 0; i < dayGap; i++) {
      final orderRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(selectedFood);

      await orderRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          double positive = (doc.data()['positive'] as num).toDouble();
          double neutral = (doc.data()['neutral'] as num).toDouble();
          double negative = (doc.data()['negative'] as num).toDouble();

          overallSentimentScore = (positive * 1) + (neutral * 0.6) + (negative * 0.2);
          DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
          if (createdAt.isAfter(startDate) &&
              createdAt.isBefore(DateTime.now())) {
            rating = (doc.data()['rating'] as num).toDouble();

            if (rating == 1) {
              onestarRating += overallSentimentScore;
              onestarRatingCount += 1;
            } else if (rating == 2) {
              twostarRating += overallSentimentScore;
              twostarRatingCount += 1;
            } else if (rating == 3) {
              threestarRating += overallSentimentScore;
              threestarRatingCount += 1;
            } else if (rating == 4) {
              fourstarRating += overallSentimentScore;
              fourstarRatingCount += 1;
            } else if (rating == 5) {
              fivestarRating += overallSentimentScore;
              fivestarRatingCount += 1;
            } else {
              print('rating not found');
            }
          }
        });
      });
    }
  }

  totalCount = onestarRatingCount + twostarRatingCount + threestarRatingCount + fourstarRatingCount + fivestarRatingCount;

  if (onestarRatingCount > 0) {
    scatterData.add(ScatterSpot(1, (onestarRating / onestarRatingCount *5), dotPainter: FlDotCirclePainter(
      radius: 20,
      color: Colors.blue[getColorShade(onestarRatingCount / totalCount)]!,
    )));
  }

  if (twostarRatingCount > 0) {
    scatterData.add(ScatterSpot(2, (twostarRating / twostarRatingCount*5), dotPainter: FlDotCirclePainter(
      radius: 20,
      color: Colors.blue[getColorShade(twostarRatingCount / totalCount)]!,
    )));
  }

  if (threestarRatingCount > 0) {
    scatterData.add(ScatterSpot(3, (threestarRating / threestarRatingCount*5), dotPainter: FlDotCirclePainter(
      radius: 20,
      color: Colors.blue[getColorShade(threestarRatingCount / totalCount)]!,
    )));
  }

  if (fourstarRatingCount > 0) {
    scatterData.add(ScatterSpot(4, (fourstarRating / fourstarRatingCount*5), dotPainter: FlDotCirclePainter(
      radius: 20,
      color: Colors.blue[getColorShade(fourstarRatingCount / totalCount)]!,
    )));
  }

  if (fivestarRatingCount > 0) {
    scatterData.add(ScatterSpot(5, (fivestarRating / fivestarRatingCount*5), dotPainter: FlDotCirclePainter(
      radius: 20,
      color: Colors.blue[getColorShade(fivestarRatingCount / totalCount)]!,
    )));
  }

  return scatterData;
}


Future<List<ScatterSpot>> returnSpecificDayScatterData(String specificDay, String selectedFood) async {
  List<ScatterSpot> scatterData = [];
  double overallSentimentScore = 0;
  double rating = 0;

  double onestarRating = 0;
  double onestarRatingCount = 0;

  double twostarRating = 0;
  double twostarRatingCount = 0;

  double threestarRating = 0;
  double threestarRatingCount = 0;

  double fourstarRating = 0;
  double fourstarRatingCount = 0;

  double fivestarRating = 0;
  double fivestarRatingCount = 0;

  double totalCount = 0;

  List menu = await getMenu();


  if (selectedFood == 'Default') {
    for (var item in menu) {
      final orderRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      await orderRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          double positive = (doc.data()['positive'] as num).toDouble();
          double neutral = (doc.data()['neutral'] as num).toDouble();
          double negative = (doc.data()['negative'] as num).toDouble();

          overallSentimentScore = (positive * 1) + (neutral * 0.6) + (negative * 0.2);
          String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
          if (createdAt == specificDay) {
            overallSentimentScore =
                (doc.data()['positive'] * 1) + doc.data()['neutral'] * 0.6 +
                    doc.data()['negative'] * 0.2;
            rating = (doc.data()['rating'] as num).toDouble();

            if (rating == 1) {
              onestarRating += overallSentimentScore;
              onestarRatingCount += 1;
            } else if (rating == 2) {
              twostarRating += overallSentimentScore;
              twostarRatingCount += 1;
            } else if (rating == 3) {
              threestarRating += overallSentimentScore;
              threestarRatingCount += 1;
            } else if (rating == 4) {
              fourstarRating += overallSentimentScore;
              fourstarRatingCount += 1;
            } else if (rating == 5) {
              fivestarRating += overallSentimentScore;
              fivestarRatingCount += 1;
            } else {
              print('rating not found');
            }
          }
        });
      });
    }
  } else {
    final orderRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    await orderRef.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
        if (createdAt == specificDay) {
          overallSentimentScore =
              (doc.data()['positive'] * 1) + doc.data()['neutral'] * 0.6 +
                  doc.data()['negative'] * 0.2;
          rating = doc.data()['rating'];

          if (rating == 1) {
            onestarRating = onestarRating + overallSentimentScore;
            onestarRatingCount = onestarRatingCount + 1;
          } else if (rating == 2) {
            twostarRating = twostarRating + overallSentimentScore;
            twostarRatingCount = twostarRatingCount + 1;
          } else if (rating == 3) {
            threestarRating = threestarRating + overallSentimentScore;
            threestarRatingCount = threestarRatingCount + 1;
          } else if (rating == 4) {
            fourstarRating = fourstarRating + overallSentimentScore;
            fourstarRatingCount = fourstarRatingCount + 1;
          } else if (rating == 5) {
            fivestarRating = fivestarRating + overallSentimentScore;
            fivestarRatingCount = fivestarRatingCount + 1;
          } else {
            print('rating not found');
          }
        }
      });
    });
  }


  totalCount = onestarRatingCount + twostarRatingCount + threestarRatingCount + fourstarRatingCount + fivestarRatingCount;

  if (onestarRatingCount > 0) {
    scatterData.add(ScatterSpot(1, (onestarRating / onestarRatingCount *5), dotPainter: FlDotCirclePainter(
      radius: 20,
      color: Colors.blue[getColorShade(onestarRatingCount / totalCount)]!,
    )));
  }

  if (twostarRatingCount > 0) {
    scatterData.add(ScatterSpot(2, (twostarRating / twostarRatingCount *5), dotPainter: FlDotCirclePainter(
      radius: 20,
      color: Colors.blue[getColorShade(twostarRatingCount / totalCount)]!,
    )));
  }

  if (threestarRatingCount > 0) {
    scatterData.add(ScatterSpot(3, (threestarRating / threestarRatingCount *5), dotPainter: FlDotCirclePainter(
      radius: 20,
      color: Colors.blue[getColorShade(threestarRatingCount / totalCount)]!,
    )));
  }

  if (fourstarRatingCount > 0) {
    scatterData.add(ScatterSpot(4, (fourstarRating / fourstarRatingCount *5), dotPainter: FlDotCirclePainter(
      radius: 20,
      color: Colors.blue[getColorShade(fourstarRatingCount / totalCount)]!,
    )));
  }

  if (fivestarRatingCount > 0) {
    scatterData.add(ScatterSpot(5, (fivestarRating / fivestarRatingCount *5), dotPainter: FlDotCirclePainter(
      radius: 20,
      color: Colors.blue[getColorShade(fivestarRatingCount / totalCount)]!,
    )));
  }


  return scatterData;
}

int getColorShade(double percentage) {
  int colorIndex = (percentage * 900).toInt();

  if (colorIndex < 100) {
    colorIndex = 100;
  } else if (colorIndex >= 100 && colorIndex < 200) {
    colorIndex = 200;
  } else if (colorIndex >= 200 && colorIndex < 300) {
    colorIndex = 300;
  } else if (colorIndex >= 300 && colorIndex < 400) {
    colorIndex = 400;
  } else if (colorIndex >= 400 && colorIndex < 500) {
    colorIndex = 500;
  } else if (colorIndex >= 500 && colorIndex < 600) {
    colorIndex = 600;
  } else if (colorIndex >= 600 && colorIndex < 700) {
    colorIndex = 700;
  } else if (colorIndex >= 700 && colorIndex < 800) {
    colorIndex = 800;
  } else if (colorIndex >= 800 && colorIndex <= 900) {
    colorIndex = 900;
  } else {
    colorIndex = 900;
  }

  return colorIndex;
}


Future<List> getMenu() async {
  List menu = [];

  final menuRef = FirebaseFirestore.instance.collection('menu');

  await menuRef.get().then((querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      menu.add(doc.data()?['name']);
    });
  });

  return menu;
}

Future<Map<String, dynamic>> getMenuCategory(String category) async {
  Map<String, dynamic> menu = {};

  final menuRef = FirebaseFirestore.instance.collection('menu');

  await menuRef.get().then((querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      if (doc.data()?['category'] == category) {
        menu[doc.data()?['name']] = doc.data();
      }
    });
  });

  return menu;
}



Future<List> getCategory() async {
  List category = [];

  final menuRef = FirebaseFirestore.instance.collection('category');

  await menuRef.get().then((querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      category.add(doc.data()?['type']);
    });
  });

  return category;
}

Future<void> addCategory(String categoryName) async {
  final categoryRef = FirebaseFirestore.instance.collection('category').doc(categoryName);
  List category = await getCategory();

  for (var item in category) {
    if (item == categoryName) {
      print('item already exist');
      return;
    }
  }

  try {
    await categoryRef.set({
      'type': categoryName,
    });
  } catch (e) {
    print('Failed to add category: $e');
  }
}

Future<void> removeCategory(String categoryName) async {
  final categoryRef = FirebaseFirestore.instance.collection('category').doc(categoryName);

  try {
    await categoryRef.delete();
    await removeMenuUnderCategory(categoryName);
  } catch (e) {
    print('Failed to add category: $e');
  }
}

Future<void> removeMenuUnderCategory(String categoryName) async {
  final menuRef = FirebaseFirestore.instance.collection('menu');

  try {
    await menuRef.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc.data()?['category'] == categoryName) {
          doc.reference.delete();
        }
      });
    });
  } catch (e) {
    print('Failed to add category: $e');
  }
}


Future<int> getMenuCounter() async {
  int counter = 0;

  final menuRef = FirebaseFirestore.instance.collection('menuCounter').doc("counter");

  await menuRef.get().then((doc) {
    counter = doc.data()?['counter'];
  });

  return counter;
}

Future<int> getTotalMeals(String selectedDate) async {
  int totalMeals = 0;

  final orderRef = FirebaseFirestore.instance
      .collection('admin')
      .doc('orders')
      .collection(selectedDate.split(' ')[0]);

  await orderRef.get().then((querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      totalMeals = totalMeals + int.parse(doc.data()['orderHistory'].length.toString());
      // totalMeals = totalMeals + doc.data()['orderHistory'].length;
    });
  });


  return totalMeals;
}

Future<int> getTotalCompletedOrders(String selectedDate) async {
  int totalOrders = 0;

  final orderRef = FirebaseFirestore.instance
      .collection('admin')
      .doc('orders')
      .collection(selectedDate.split(' ')[0]);

  await orderRef.get().then((querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      if (doc.data()['status'] == 'Completed' || doc.data()['status'] == 'Completed and Reviewed') {
        totalOrders = totalOrders + 1;
      }
    });
  });

  return totalOrders;
}


Future<int> getTotalPendingOrders(String selectedDate) async {
  int pendingOrders = 0;

  final orderRef = FirebaseFirestore.instance
      .collection('admin')
      .doc('orders')
      .collection(selectedDate.split(' ')[0]);

  await orderRef.get().then((querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      if (doc.data()['status'] == 'Pending') {
        pendingOrders = pendingOrders + 1;
      }
      if (doc.data()['status'] == 'Ready') {
        pendingOrders = pendingOrders + 1;
      }
    });
  });


  return pendingOrders;
}

Future<String> getUsername(String userID) async {
  String username = "";

  final userRef = FirebaseFirestore.instance.collection('users').doc(userID);

  await userRef.get().then((doc) {
    username = doc.data()?['username'];
  });

  return username;
}

Future<String> getProfileImage(String userID) async {
  String profileImage = "";

  final userRef = FirebaseFirestore.instance.collection('users').doc(userID);

  await userRef.get().then((doc) {
    profileImage = doc.data()?['profileImage'];
  });

  String downloadURL = await _storage.ref('users/${userID}.jpeg').getDownloadURL();



  return downloadURL;
}

Future<String> getMenuImage(String imageURL) async {
  String downloadURL = "";

  downloadURL = await _storage.ref('menu/${imageURL}.jpeg').getDownloadURL();

  return downloadURL;
}



void updateOrderStatus(String orderID, String userID, String status, String selectedDate) async {

  final userRef = FirebaseFirestore
      .instance
      .collection('users')
      .doc(userID)
      .collection('history')
      .doc(orderID);

  final adminRef = FirebaseFirestore
      .instance
      .collection('admin')
      .doc('orders')
      .collection(selectedDate.split(' ')[0])
      .doc(orderID);

   userRef.update({
    'status': status,
  });

   adminRef.update({
    'status': status,
  });
}

Future<String> analyzeComment(String inputText) async {
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

  return response[0][0]['label'];
}

Future<Map<String, double>> returnSentiment(String timeRange, String selectedFood) async {
  Map<String, double> sentimentCount = {
    'positive': 0,
    'negative': 0,
    'neutral': 0,
  };

  List menu = await getMenu();
  double positive = 0;
  double negative = 0;
  double neutral = 0;

  DateTime startDate;

  // Determine the start date based on the time range selected
  if (timeRange == 'Today') {
    startDate = DateTime.now().subtract(Duration(days: 0)); // today
  } else if (timeRange == 'Yesterday') {
    startDate = DateTime.now().subtract(Duration(days: 1));
  } else if (timeRange == 'This Week') {
    startDate = DateTime.now().subtract(Duration(days: 7));
  } else if (timeRange == 'This Month') {
    startDate = DateTime(DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);
  } else if (timeRange == 'This Year') {
    startDate = DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
  } else if (timeRange == 'All Time') {
    startDate = DateTime(2021, 1, 1);
  } else {
    startDate = DateTime.now();
  }

  if (selectedFood == "Default") {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      final querySnapshot = await reviewRef.get();

      for (var doc in querySnapshot.docs) {
        DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
        if (createdAt.isAfter(startDate) && createdAt.isBefore(DateTime.now())) {
          positive = (doc.data()?['positive'] ?? 0).toDouble();
          neutral = (doc.data()?['neutral'] ?? 0).toDouble();
          negative = (doc.data()?['negative'] ?? 0).toDouble();

          if (positive > 0 || neutral > 0 || negative > 0) {
            sentimentCount['positive'] = (sentimentCount['positive'] ?? 0) + positive;
            sentimentCount['negative'] = (sentimentCount['negative'] ?? 0) + negative;
            sentimentCount['neutral'] = (sentimentCount['neutral'] ?? 0) + neutral;
          }
        }
      }
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
      if (createdAt.isAfter(startDate) && createdAt.isBefore(DateTime.now())) {
        positive = (doc.data()?['positive'] ?? 0).toDouble(); // Convert to double
        neutral = (doc.data()?['neutral'] ?? 0).toDouble(); // Convert to double
        negative = (doc.data()?['negative'] ?? 0).toDouble(); // Convert to double

        // Check if values are not zero before adding to sentimentCount
        if (positive > 0 || neutral > 0 || negative > 0) {
          sentimentCount['positive'] = (sentimentCount['positive'] ?? 0) + positive;
          sentimentCount['negative'] = (sentimentCount['negative'] ?? 0) + negative;
          sentimentCount['neutral'] = (sentimentCount['neutral'] ?? 0) + neutral;
        }
      }
    }
  }

  return sentimentCount;
}



Future<Map<String, double>> returnSpecificDaySentiment(String specificDay, String selectedFood) async {
  Map<String, double> sentimentCount = {
    'positive': 0,
    'negative': 0,
    'neutral': 0,
  };
  List menu = await getMenu();


  double positive = 0;
  double negative = 0;
  double neutral = 0;


  if (selectedFood == "Default") {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      final querySnapshot = await reviewRef.get();

      for (var doc in querySnapshot.docs) {
        String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
        if (createdAt == specificDay) {
          positive = (doc.data()?['positive'] ?? 0).toDouble(); // Convert to double
          neutral = (doc.data()?['neutral'] ?? 0).toDouble(); // Convert to double
          negative = (doc.data()?['negative'] ?? 0).toDouble(); // Convert to double

          // Check if values are not zero before adding to sentimentCount
          if (positive > 0 || neutral > 0 || negative > 0) {
            sentimentCount['positive'] = (sentimentCount['positive'] ?? 0) + positive;
            sentimentCount['negative'] = (sentimentCount['negative'] ?? 0) + negative;
            sentimentCount['neutral'] = (sentimentCount['neutral'] ?? 0) + neutral;
          }
        }
      }
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
      if (createdAt == specificDay) {
        positive = doc.data()?['positive'];
        neutral = doc.data()?['neutral'];
        negative = doc.data()?['negative'];

        if (positive == 0 && neutral == 0 && negative == 0) {
          continue;
        } else {
          sentimentCount['positive'] = (sentimentCount['positive'] ?? 0) + positive;
          sentimentCount['negative'] = (sentimentCount['negative'] ?? 0) + negative;
          sentimentCount['neutral'] = (sentimentCount['neutral'] ?? 0) + neutral;
        }
      }
    }
  }

  return sentimentCount;
}

Future<List<Map>> returnWordCloud(String timeRange, String selectedFood) async {
  List<Map> wordCloud = [];
  Map<String, double> tempWordCloud = {};

  List menu = await getMenu();

  DateTime startDate;

  final RegExp punctuationRegex = RegExp(r'[^\w\s]');
  final Set<String> stopWords = {'the', 'and', 'is', 'in', 'to', 'with', 'a', 'of', 'on', 'for', 'it', 'that', 'as', 'at', 'by', 'an', 'are', 'was', 'were', 'this', 'which', 'or', 'from'};


  if (timeRange == 'Today') {
    startDate = DateTime.now();
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
  } else if (timeRange == 'Yesterday') {
    startDate = DateTime.now().subtract(Duration(days: 1));
  } else if (timeRange == 'This Week') {
    startDate = DateTime.now().subtract(Duration(days: 7));
  } else if (timeRange == 'This Month') {
    startDate = DateTime(DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);
  } else if (timeRange == 'This Year') {
    startDate = DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
  } else if (timeRange == 'All Time') {
    //set it to a date that is way before the app is created
    //doesnt matter what it is
    startDate = DateTime(2021, 1, 1);
  } else {
    startDate = DateTime.now();
  }

  if (selectedFood == "Default") {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      final querySnapshot = await reviewRef.get();

      for (var doc in querySnapshot.docs) {
        DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
        if (createdAt.isAfter(startDate) &&
            createdAt.isBefore(DateTime.now())) {
          for (var word in doc.data()?['comment']
              .toLowerCase()
              .replaceAll(punctuationRegex, '')
              .split(' ')
              .where((word) => word.isNotEmpty && !stopWords.contains(word))) {
            tempWordCloud[word] = (tempWordCloud[word] ?? 0) + 1;
          }
        }
      }
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
      if (createdAt.isAfter(startDate) &&
          createdAt.isBefore(DateTime.now())) {
        for (var word in doc.data()?['comment']
            .toLowerCase()
            .replaceAll(punctuationRegex, '')
            .split(' ')
            .where((word) => word.isNotEmpty && !stopWords.contains(word))) {
          tempWordCloud[word] = (tempWordCloud[word] ?? 0) + 1;
        }
      }
    }
  }

  for (var key in tempWordCloud.keys) {
    wordCloud.add({'word': key, 'value': tempWordCloud[key]});
  }


  return wordCloud;
}

Future<List<Map>> returnSpecificDayWordCloud(String specificDay, String selectedFood) async {
  List<Map> wordCloud = [];
  Map<String, double> tempWordCloud = {};

  List menu = await getMenu();

  DateTime startDate;

  final RegExp punctuationRegex = RegExp(r'[^\w\s]');
  final Set<String> stopWords = {'the', 'and', 'is', 'in', 'to', 'with', 'a', 'of', 'on', 'for', 'it', 'that', 'as', 'at', 'by', 'an', 'are', 'was', 'were', 'this', 'which', 'or', 'from'};

  if (selectedFood == "Default") {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      final querySnapshot = await reviewRef.get();

      for (var doc in querySnapshot.docs) {
        String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
        if (createdAt == specificDay) {
          for (var word in doc.data()?['comment']
              .toLowerCase()
              .replaceAll(punctuationRegex, '')
              .split(' ')
              .where((word) => word.isNotEmpty && !stopWords.contains(word))) {
            tempWordCloud[word] = (tempWordCloud[word] ?? 0) + 1;
          }
        }
      }
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
      if (createdAt == specificDay) {
        for (var word in doc.data()?['comment']
            .toLowerCase()
            .replaceAll(punctuationRegex, '')
            .split(' ')
            .where((word) => word.isNotEmpty && !stopWords.contains(word))) {
          tempWordCloud[word] = (tempWordCloud[word] ?? 0) + 1;
        }
      }
    }
  }

  for (var key in tempWordCloud.keys) {
    wordCloud.add({'word': key, 'value': tempWordCloud[key]});
  }


  return wordCloud;
}

Future<int> returnWordCloudCounter(String timeRange, String selectedFood) async {
  Map<String, double> tempWordCloud = {};

  List menu = await getMenu();
  int counter = 0;
  DateTime startDate;

  final RegExp punctuationRegex = RegExp(r'[^\w\s]');
  final Set<String> stopWords = {'the', 'and', 'is', 'in', 'to', 'with', 'a', 'of', 'on', 'for', 'it', 'that', 'as', 'at', 'by', 'an', 'are', 'was', 'were', 'this', 'which', 'or', 'from'};


  if (timeRange == 'Today') {
    startDate = DateTime.now();
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
  } else if (timeRange == 'Yesterday') {
    startDate = DateTime.now().subtract(Duration(days: 1));
  } else if (timeRange == 'This Week') {
    startDate = DateTime.now().subtract(Duration(days: 7));
  } else if (timeRange == 'This Month') {
    startDate = DateTime(DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);
  } else if (timeRange == 'This Year') {
    startDate = DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
  } else if (timeRange == 'All Time') {
    //set it to a date that is way before the app is created
    //doesnt matter what it is
    startDate = DateTime(2021, 1, 1);
  } else {
    startDate = DateTime.now();
  }

  if (selectedFood == "Default") {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      final querySnapshot = await reviewRef.get();

      for (var doc in querySnapshot.docs) {
        DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
        if (createdAt.isAfter(startDate) &&
            createdAt.isBefore(DateTime.now())) {
          for (var word in doc.data()?['comment']
              .toLowerCase()
              .replaceAll(punctuationRegex, '')
              .split(' ')
              .where((word) => word.isNotEmpty && !stopWords.contains(word))) {
            tempWordCloud[word] = (tempWordCloud[word] ?? 0) + 1;
          }
          counter++;
        }
      }
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
      if (createdAt.isAfter(startDate) &&
          createdAt.isBefore(DateTime.now())) {
        for (var word in doc.data()?['comment']
            .toLowerCase()
            .replaceAll(punctuationRegex, '')
            .split(' ')
            .where((word) => word.isNotEmpty && !stopWords.contains(word))) {
          tempWordCloud[word] = (tempWordCloud[word] ?? 0) + 1;
        }
        counter++;
      }
    }
  }

  return counter;
}

Future<int> returnSpecificDayWordCloudCounter(String specificDay, String selectedFood) async {
  Map<String, double> tempWordCloud = {};

  List menu = await getMenu();
  int counter = 0;
  DateTime startDate;

  final RegExp punctuationRegex = RegExp(r'[^\w\s]');
  final Set<String> stopWords = {'the', 'and', 'is', 'in', 'to', 'with', 'a', 'of', 'on', 'for', 'it', 'that', 'as', 'at', 'by', 'an', 'are', 'was', 'were', 'this', 'which', 'or', 'from'};


  if (selectedFood == "Default") {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      final querySnapshot = await reviewRef.get();

      for (var doc in querySnapshot.docs) {
        String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
        if (createdAt == specificDay) {
          for (var word in doc.data()?['comment']
              .toLowerCase()
              .replaceAll(punctuationRegex, '')
              .split(' ')
              .where((word) => word.isNotEmpty && !stopWords.contains(word))) {
            tempWordCloud[word] = (tempWordCloud[word] ?? 0) + 1;
          }
          counter++;
        }
      }
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
      if (createdAt == specificDay) {
        for (var word in doc.data()?['comment']
            .toLowerCase()
            .replaceAll(punctuationRegex, '')
            .split(' ')
            .where((word) => word.isNotEmpty && !stopWords.contains(word))) {
          tempWordCloud[word] = (tempWordCloud[word] ?? 0) + 1;
        }
        counter++;
      }
    }
  }

  return counter;
}


Future<List<VBarChartModel>> returnWordFrequency(String timeRange, String selectedFood) async {
  List<VBarChartModel> bardata = [];
  Map<String, double> tempWordCloud = {};

  List menu = await getMenu();
  String comment = '';
  int counter = 0;

  final RegExp punctuationRegex = RegExp(r'[^\w\s]');
  final Set<String> stopWords = {'the', 'and', 'is', 'in', 'to', 'with', 'a', 'of', 'on', 'for', 'it', 'that', 'as', 'at', 'by', 'an', 'are', 'was', 'were', 'this', 'which', 'or', 'from'};

  DateTime startDate;

  if (timeRange == 'Today') {
    startDate = DateTime.now();
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
  } else if (timeRange == 'Yesterday') {
    startDate = DateTime.now().subtract(Duration(days: 1));
  } else if (timeRange == 'This Week') {
    startDate = DateTime.now().subtract(Duration(days: 7));
  } else if (timeRange == 'This Month') {
    startDate = DateTime(DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);
  } else if (timeRange == 'This Year') {
    startDate = DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
  } else if (timeRange == 'All Time') {
    //set it to a date that is way before the app is created
    //doesnt matter what it is
    startDate = DateTime(2021, 1, 1);
  } else {
    startDate = DateTime.now();
  }

  if (selectedFood == "Default") {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      final querySnapshot = await reviewRef.get();

      for (var doc in querySnapshot.docs) {
        DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
        if (createdAt.isAfter(startDate) &&
            createdAt.isBefore(DateTime.now())) {
          for (var word in doc.data()?['comment']
              .toLowerCase()
              .replaceAll(punctuationRegex, '')
              .split(' ')
              .where((word) => word.isNotEmpty && !stopWords.contains(word))) {
            tempWordCloud[word] = (tempWordCloud[word] ?? 0) + 1;
          }
        }
      }
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
      if (createdAt.isAfter(startDate) &&
          createdAt.isBefore(DateTime.now())) {
        for (var word in doc.data()?['comment']
            .toLowerCase()
            .replaceAll(punctuationRegex, '')
            .split(' ')
            .where((word) => word.isNotEmpty && !stopWords.contains(word))) {
          tempWordCloud[word] = (tempWordCloud[word] ?? 0) + 1;
        }
      }
    }
  }

  var sortedEntries = tempWordCloud.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  for (var entry in sortedEntries) {
    bardata.add(VBarChartModel(
      index: counter,
      label: entry.key,
      colors: [Colors.orange, Colors.deepOrange],
      jumlah: entry.value,
      tooltip: entry.value.toString(),
    ));
    counter++;
  }


  return bardata;
}

Future<double> returnMaxXWordFrequency(String timeRange, String selectedFood) async {
  List<VBarChartModel> bardata = [];
  Map<String, double> tempWordCloud = {};

  List menu = await getMenu();
  String comment = '';
  int counter = 0;
  String highestWord = '';
  double highestValue = 0;

  final RegExp punctuationRegex = RegExp(r'[^\w\s]');
  final Set<String> stopWords = {'the', 'and', 'is', 'in', 'to', 'with', 'a', 'of', 'on', 'for', 'it', 'that', 'as', 'at', 'by', 'an', 'are', 'was', 'were', 'this', 'which', 'or', 'from'};

  DateTime startDate;

  if (timeRange == 'Today') {
    startDate = DateTime.now();
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
  } else if (timeRange == 'Yesterday') {
    startDate = DateTime.now().subtract(Duration(days: 1));
  } else if (timeRange == 'This Week') {
    startDate = DateTime.now().subtract(Duration(days: 7));
  } else if (timeRange == 'This Month') {
    startDate = DateTime(DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);
  } else if (timeRange == 'This Year') {
    startDate = DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
  } else if (timeRange == 'All Time') {
    //set it to a date that is way before the app is created
    //doesnt matter what it is
    startDate = DateTime(2021, 1, 1);
  } else {
    startDate = DateTime.now();
  }

  if (selectedFood == "Default") {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      final querySnapshot = await reviewRef.get();

      for (var doc in querySnapshot.docs) {
        DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
        if (createdAt.isAfter(startDate) &&
            createdAt.isBefore(DateTime.now())) {
          for (var word in doc.data()?['comment']
              .toLowerCase()
              .replaceAll(punctuationRegex, '')
              .split(' ')
              .where((word) => word.isNotEmpty && !stopWords.contains(word))) {
            tempWordCloud[word] = (tempWordCloud[word] ?? 0) + 1;
          }
        }
      }
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
      if (createdAt.isAfter(startDate) &&
          createdAt.isBefore(DateTime.now())) {
        for (var word in doc.data()?['comment']
            .toLowerCase()
            .replaceAll(punctuationRegex, '')
            .split(' ')
            .where((word) => word.isNotEmpty && !stopWords.contains(word))) {
          tempWordCloud[word] = (tempWordCloud[word] ?? 0) + 1;
        }
      }
    }
  }

  var sortedEntries = tempWordCloud.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  for (var entry in sortedEntries) {
    bardata.add(VBarChartModel(
      index: counter,
      label: entry.key,
      colors: [Colors.orange, Colors.deepOrange],
      jumlah: entry.value,
      tooltip: entry.value.toString(),
    ));

    if (entry.value > highestValue) {
      highestValue = entry.value;
      highestWord = entry.key;
    }

    counter++;
  }


  return highestValue;
}


Future<double> returnSpecificDayMaxXWordFrequency(String specificDay, String selectedFood) async {
  List<VBarChartModel> bardata = [];
  Map<String, double> tempWordCloud = {};

  List menu = await getMenu();
  String comment = '';
  int counter = 0;
  String highestWord = '';
  double highestValue = 0;

  final RegExp punctuationRegex = RegExp(r'[^\w\s]');
  final Set<String> stopWords = {'the', 'and', 'is', 'in', 'to', 'with', 'a', 'of', 'on', 'for', 'it', 'that', 'as', 'at', 'by', 'an', 'are', 'was', 'were', 'this', 'which', 'or', 'from'};

  DateTime startDate;

  if (selectedFood == "Default") {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      final querySnapshot = await reviewRef.get();

      for (var doc in querySnapshot.docs) {
        String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
        if (createdAt == specificDay) {
          for (var word in doc.data()?['comment']
              .toLowerCase()
              .replaceAll(punctuationRegex, '')
              .split(' ')
              .where((word) => word.isNotEmpty && !stopWords.contains(word))) {
            tempWordCloud[word] = (tempWordCloud[word] ?? 0) + 1;
          }
        }
      }
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
      if (createdAt == specificDay) {
        for (var word in doc.data()?['comment']
            .toLowerCase()
            .replaceAll(punctuationRegex, '')
            .split(' ')
            .where((word) => word.isNotEmpty && !stopWords.contains(word))) {
          tempWordCloud[word] = (tempWordCloud[word] ?? 0) + 1;
        }
      }
    }
  }

  var sortedEntries = tempWordCloud.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  for (var entry in sortedEntries) {
    bardata.add(VBarChartModel(
      index: counter,
      label: entry.key,
      colors: [Colors.orange, Colors.deepOrange],
      jumlah: entry.value,
      tooltip: entry.value.toString(),
    ));

    if (entry.value > highestValue) {
      highestValue = entry.value;
      highestWord = entry.key;
    }

    counter++;
  }


  return highestValue;
}


Future<List<VBarChartModel>> returnSpecificDayWordFrequency(String specificDay, String selectedFood) async {
  List<VBarChartModel> bardata = [];
  Map<String, double> tempWordCloud = {};

  List menu = await getMenu();
  String comment = '';
  int counter = 0;

  final RegExp punctuationRegex = RegExp(r'[^\w\s]');
  final Set<String> stopWords = {'the', 'and', 'is', 'in', 'to', 'with', 'a', 'of', 'on', 'for', 'it', 'that', 'as', 'at', 'by', 'an', 'are', 'was', 'were', 'this', 'which', 'or', 'from'};

  DateTime startDate;


  if (selectedFood == "Default") {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      final querySnapshot = await reviewRef.get();

      for (var doc in querySnapshot.docs) {
        String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
        if (createdAt == specificDay) {
          for (var word in doc.data()?['comment']
              .toLowerCase()
              .replaceAll(punctuationRegex, '')
              .split(' ')
              .where((word) => word.isNotEmpty && !stopWords.contains(word))) {
            tempWordCloud[word] = (tempWordCloud[word] ?? 0) + 1;
          }
        }
      }
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
      if (createdAt == specificDay) {
        for (var word in doc.data()?['comment']
            .toLowerCase()
            .replaceAll(punctuationRegex, '')
            .split(' ')
            .where((word) => word.isNotEmpty && !stopWords.contains(word))) {
          tempWordCloud[word] = (tempWordCloud[word] ?? 0) + 1;
        }
      }
    }
  }

  var sortedEntries = tempWordCloud.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  for (var entry in sortedEntries) {
    bardata.add(VBarChartModel(
      index: counter,
      label: entry.key,
      colors: [Colors.orange, Colors.deepOrange],
      jumlah: entry.value,
      tooltip: entry.value.toString(),
    ));
    counter++;
  }


  return bardata;
}


Future<List<VBarChartModel>> returnMenuRating(String timeRange, String selectedFood) async {
  List<VBarChartModel> bardata = [];
  Map<String, double> totalRating = {};
  Map<String, double> totalCounter = {};
  Map<String, double> averageRating = {};

  List menu = await getMenu();
  String comment = '';
  int counter = 0;
  int barChartCounter = 0;

  DateTime startDate;

  if (timeRange == 'Today') {
    startDate = DateTime.now();
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
  } else if (timeRange == 'Yesterday') {
    startDate = DateTime.now().subtract(Duration(days: 1));
  } else if (timeRange == 'This Week') {
    startDate = DateTime.now().subtract(Duration(days: 7));
  } else if (timeRange == 'This Month') {
    startDate = DateTime(DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);
  } else if (timeRange == 'This Year') {
    startDate = DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
  } else if (timeRange == 'All Time') {
    //set it to a date that is way before the app is created
    //doesnt matter what it is
    startDate = DateTime(2021, 1, 1);
  } else {
    startDate = DateTime.now();
  }

  if (selectedFood == "Default") {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      final querySnapshot = await reviewRef.get();

      for (var doc in querySnapshot.docs) {
        DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
        if (createdAt.isAfter(startDate) &&
            createdAt.isBefore(DateTime.now())) {
          totalRating[item] = (totalRating[item] ?? 0) + doc.data()?['rating'];
          totalCounter[item] = (totalCounter[item] ?? 0) + 1;
        }
      }

      if (totalCounter[item] != null && totalCounter[item]! > 0) {
        averageRating[item] = totalRating[item]! / totalCounter[item]!;
      }
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
      if (createdAt.isAfter(startDate) &&
          createdAt.isBefore(DateTime.now())) {
        totalRating[selectedFood] = (totalRating[selectedFood] ?? 0) + doc.data()?['rating'];
        totalCounter[selectedFood] = (totalCounter[selectedFood] ?? 0) + 1;
      }
    }

    if (totalCounter[selectedFood] != null && totalCounter[selectedFood]! > 0) {
      averageRating[selectedFood] = totalRating[selectedFood]! / totalCounter[selectedFood]!;
    }
  }

  var sortedEntries = averageRating.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  for (var entry in sortedEntries) {
    bardata.add(VBarChartModel(
      index: barChartCounter,
      label: entry.key,
      colors: [Colors.orange, Colors.deepOrange],
      jumlah: entry.value,
      tooltip: "${entry.value.toStringAsFixed(2)} Stars",
    ));
    barChartCounter++;
  }


  return bardata;
}

Future<List<VBarChartModel>> returnSpecificDayMenuRating(String specificDay, String selectedFood) async {
  List<VBarChartModel> bardata = [];
  Map<String, double> totalRating = {};
  Map<String, double> totalCounter = {};
  Map<String, double> averageRating = {};

  List menu = await getMenu();
  String comment = '';
  int counter = 0;
  int barChartCounter = 0;

  DateTime startDate;

  if (selectedFood == "Default") {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      final querySnapshot = await reviewRef.get();

      for (var doc in querySnapshot.docs) {
        String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
        if (createdAt == specificDay) {
          totalRating[item] = (totalRating[item] ?? 0) + doc.data()?['rating'];
          totalCounter[item] = (totalCounter[item] ?? 0) + 1;
        }
      }

      if (totalCounter[item] != null && totalCounter[item]! > 0) {
        averageRating[item] = totalRating[item]! / totalCounter[item]!;
      }
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
      if (createdAt == specificDay) {
        totalRating[selectedFood] = (totalRating[selectedFood] ?? 0) + doc.data()?['rating'];
        totalCounter[selectedFood] = (totalCounter[selectedFood] ?? 0) + 1;
      }
    }

    if (totalCounter[selectedFood] != null && totalCounter[selectedFood]! > 0) {
      averageRating[selectedFood] = totalRating[selectedFood]! / totalCounter[selectedFood]!;
    }
  }

  var sortedEntries = averageRating.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  for (var entry in sortedEntries) {
    bardata.add(VBarChartModel(
      index: barChartCounter,
      label: entry.key,
      colors: [Colors.orange, Colors.deepOrange],
      jumlah: entry.value,
      tooltip: "${entry.value.toStringAsFixed(2)} Stars",
    ));
    barChartCounter++;
  }


  return bardata;
}

Future<Map<String, Map<String, double>>> returnSentimentRating(String timeRange, String selectedFood) async {
  Map<String, Map<String, double>> sentimentCount = {};

  Map<String, double> totalRating = {};
  Map<String, double> totalCounter = {};
  Map<String, double> averageRating = {};

  List menu = await getMenu();

  for (var item in menu) {
    sentimentCount[item] = {
      'positive': 0.0,
      'negative': 0.0,
      'neutral': 0.0,
      'count' : 0.0,
    };
  }

  DateTime startDate;

  if (timeRange == 'Today') {
    startDate = DateTime.now();
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
  } else if (timeRange == 'Yesterday') {
    startDate = DateTime.now().subtract(Duration(days: 1));
  } else if (timeRange == 'This Week') {
    startDate = DateTime.now().subtract(Duration(days: 7));
  } else if (timeRange == 'This Month') {
    startDate = DateTime(DateTime.now().year, DateTime.now().month - 1, DateTime.now().day);
  } else if (timeRange == 'This Year') {
    startDate = DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
  } else if (timeRange == 'All Time') {
    //set it to a date that is way before the app is created
    //doesnt matter what it is
    startDate = DateTime(2021, 1, 1);
  } else {
    startDate = DateTime.now();
  }

  if (selectedFood == "Default") {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      final querySnapshot = await reviewRef.get();

      for (var doc in querySnapshot.docs) {
        DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
        if (createdAt.isAfter(startDate) &&
            createdAt.isBefore(DateTime.now())) {
          sentimentCount[item]?['positive'] = (sentimentCount[item]!['positive']! + doc.data()?['positive'])!;
          sentimentCount[item]?['negative'] = (sentimentCount[item]!['negative']! + doc.data()?['negative'])!;
          sentimentCount[item]?['neutral'] = (sentimentCount[item]!['neutral']! + doc.data()?['neutral'])!;
          sentimentCount[item]?['count'] = (sentimentCount[item]!['count']! + 1);
        }
      }
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
      if (createdAt.isAfter(startDate) &&
          createdAt.isBefore(DateTime.now())) {
        sentimentCount[selectedFood]?['positive'] = (sentimentCount[selectedFood]!['positive']! + doc.data()?['positive'])!;
        sentimentCount[selectedFood]?['negative'] = (sentimentCount[selectedFood]!['negative']! + doc.data()?['negative'])!;
        sentimentCount[selectedFood]?['neutral'] = (sentimentCount[selectedFood]!['neutral']! + doc.data()?['neutral'])!;
        sentimentCount[selectedFood]?['count'] = (sentimentCount[selectedFood]!['count']! + 1);
      }
    }
  }

  return sentimentCount;
}

Future<Map<String, Map<String, double>>> returnSpecificDaySentimentRating(String specificDay, String selectedFood) async {
  Map<String, Map<String, double>> sentimentCount = {};

  Map<String, double> totalRating = {};
  Map<String, double> totalCounter = {};
  Map<String, double> averageRating = {};

  List menu = await getMenu();

  for (var item in menu) {
    sentimentCount[item] = {
      'positive': 0.0,
      'negative': 0.0,
      'neutral': 0.0,
      'count' : 0.0,
    };
  }

  if (selectedFood == "Default") {
    for (var item in menu) {
      final reviewRef = FirebaseFirestore.instance
          .collection('admin')
          .doc('reviews')
          .collection(item);

      final querySnapshot = await reviewRef.get();

      for (var doc in querySnapshot.docs) {
        String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
        if (createdAt == specificDay) {
          sentimentCount[item]?['positive'] = (sentimentCount[item]!['positive']! + doc.data()?['positive'])!;
          sentimentCount[item]?['negative'] = (sentimentCount[item]!['negative']! + doc.data()?['negative'])!;
          sentimentCount[item]?['neutral'] = (sentimentCount[item]!['neutral']! + doc.data()?['neutral'])!;
          sentimentCount[item]?['count'] = (sentimentCount[item]!['count']! + 1);
        }
      }
    }
  } else {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(selectedFood);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      String? createdAt = doc.data()?['createdAt'].toString().split(' ')[0];
      if (createdAt == specificDay) {
        sentimentCount[selectedFood]?['positive'] = (sentimentCount[selectedFood]!['positive']! + doc.data()?['positive'])!;
        sentimentCount[selectedFood]?['negative'] = (sentimentCount[selectedFood]!['negative']! + doc.data()?['negative'])!;
        sentimentCount[selectedFood]?['neutral'] = (sentimentCount[selectedFood]!['neutral']! + doc.data()?['neutral'])!;
        sentimentCount[selectedFood]?['count'] = (sentimentCount[selectedFood]!['count']! + 1);
      }
    }
  }

  return sentimentCount;
}

void updateMenu(String name, String description, String category, double price, String imageName) async {
  final menuRef = FirebaseFirestore.instance.collection('menu').doc(imageName);


  try {
    await menuRef.update({
      'name': name,
      'description': description,
      'category': category,
      'price': price,
    });
  } catch (e) {
    print('Failed to update menu: $e');
  }
}

void addMenu(String name, String description, String category, double price, String imageName) async {
  final menuRef = FirebaseFirestore.instance.collection('menu').doc(imageName);

  final counterRef = FirebaseFirestore.instance.collection('menuCounter').doc("counter");

  counterRef.update({
    'counter': FieldValue.increment(1),
  });

  try {
    await menuRef.set({
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageURL': imageName,
      'createdAt': DateTime.now().toString(),
      'rating': 0,
      'totalRating': 0,
      'totalUsersRating': 0,

    });
  } catch (e) {
    print('Failed to update menu: $e');
  }
}

void deleteMenu(String imageName) async {
  final menuRef = FirebaseFirestore.instance.collection('menu').doc(imageName);


  try {
    await menuRef.delete();
  } catch (e) {
    print('Failed to delete menu: $e');
  }
}

void TopupUserWallet(String userID, double amount) {
  final userDocumentRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userID);

  userDocumentRef.get().then((value) {
    double currentBalance = (value.get('balance') as num).toDouble();
    double newBalance = currentBalance + amount;
    userDocumentRef.update({'balance': newBalance});
  });

  Random random = Random();
  int randomNumber = random.nextInt(1000000000) + 1;

  //creates income history
  createOrderHistory(userID, [], "", "", amount, randomNumber, "", "Topup");

}

void createOrderHistory(String userID, List cartItems, String specialRemarks, String desiredPickupTime, double total, int uniqueID, String paymentMethod, String type) {
  final orderCollectionRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userID)
      .collection('history')
      .doc(uniqueID.toString());

  List<Map<String, dynamic>> orderHistory = cartItems.map((item) => {
    'name': item.name,
    'quantity': item.quantity,
    'price': item.price,
    'total': item.total,
    'imageURL': item.imageURL,
  }).toList();

  orderCollectionRef.set({
    'id': uniqueID,
    'orderHistory': orderHistory,
    'status': 'Pending',
    'createdAt': DateTime.now().toString(),
    'specialRemarks': specialRemarks,
    'desiredPickupTime': desiredPickupTime,
    'total': total,
    'paymentMethod': paymentMethod,
    'type': type,
  });
}

String TimestampFormatter(String timestamp) {
  DateTime dateTime = DateTime.parse(timestamp);
  String formattedDate = DateFormat('dd MMMM yyyy HH:mm').format(dateTime);
  return formattedDate;
}

String HourFormatter(String timestamp) {
  DateTime dateTime = DateTime.parse(timestamp);
  String formattedDate = DateFormat('hh:mm a').format(dateTime);
  return formattedDate;
}

String DayMonthYearFormatter(String timestamp) {
  DateTime dateTime = DateTime.parse(timestamp);
  String formattedDate = DateFormat('dd MMMM yyyy').format(dateTime);
  return formattedDate;
}

String TimestampToStringFormatter(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  String formattedDate = DateFormat('dd MMMM yyyy HH:mm').format(dateTime);
  return formattedDate;
}

String DaysFromTimeStamp(String timestamp) {
  DateTime dateTime = DateTime.parse(timestamp);
  DateTime now = DateTime.now();
  int difference = now.difference(dateTime).inDays;

  if (difference == 0) {
    return 'Today';
  } else if (difference == 1) {
    return 'Yesterday';
  } else if (difference > 30) {
    return ((difference/30).round()).toString() + ' months ago';
  } else {
    return difference.toString() + ' days ago';
  }

}

String PickupTimestampFormatter(String timestamp, String desiredPickupTime) {
  DateTime dateTime = DateTime.parse(timestamp);
  String strippedTime = desiredPickupTime.split(' ')[0];
  int strippedHour = int.parse(strippedTime.split(':')[0]);
  int strippedMinute =int.parse(strippedTime.split(':')[1]);
  dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day + 1, strippedHour, strippedMinute);
  String formattedDate = DateFormat('dd MMMM yyyy HH:mm').format(dateTime);
  return formattedDate;
}

String wordLimit(String text, int wordLimit) {
  final words = text.split(' ');
  if (words.length > wordLimit) {
    return words.take(wordLimit).join(' ') + '...';
  } else {
    return text;
  }
}

//parsing vader lexicon
void parseLexiconData(String data) {
  Map<String, double> newWords = {'genius': 5.2, };

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

Future<String> returnUsernameWithID(String userID) async {
  String username = "";

  final userRef = FirebaseFirestore.instance.collection('users').doc(userID);

  await userRef.get().then((doc) {
    username = doc.data()?['username'];
  });

  return username;
}

Future<double> returnBalanceWithID(String userID) async {
  double balance = 0;

  final userRef = FirebaseFirestore.instance.collection('users').doc(userID);

  await userRef.get().then((doc) {
    var balanceData = doc.data()?['balance'];

    if (balanceData is int) {
      balance = balanceData.toDouble(); // Convert int to double
    } else if (balanceData is double) {
      balance = balanceData;
    } else if (balanceData is String) {
      balance = double.parse(balanceData); // Parse if it's a String
    }
  });

  return balance;
}

void updateQrCodeStatus(String uniqueID) {
  final qrCodeRef = FirebaseFirestore.instance.collection('qrCodes').doc(uniqueID);

  qrCodeRef.update({
    'scanned': true,
  });
}

void updateAdminHistoryStatus(String desiredPickupTime, int orderID) {
  final adminHistoryRef = FirebaseFirestore.instance
      .collection('admin')
      .doc('orders')
      .collection(desiredPickupTime.split(' ')[0]).doc(orderID.toString());

  adminHistoryRef.update({
    'status': 'Completed',
    'completedAt': DateTime.now().toString(),
  });

}

Future<String> returnUsernameWithUniqueID(String uniqueID) async {
  String username = "";

  final qrCodeRef = FirebaseFirestore.instance.collection('qrCodes').doc(uniqueID);

  await qrCodeRef.get().then((doc) async {
    String userID = doc.data()?['userId'];
    username = await returnUsernameWithID(userID);
  });
  print(username);

  return username;
}

Future<String> returnAmountWithUniqueID(String uniqueID) async {
  int amount = 0;

  final qrCodeRef = FirebaseFirestore.instance.collection('qrCodes').doc(uniqueID);

  await qrCodeRef.get().then((doc) {
    amount = doc.data()?['amount'];
  });

  print(amount.toString());

  return amount.toString();
}

Future<void> logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
  );
}

Future<void> sendNotification(String title, String body, String userID) async {
  String fcmToken = await returnFcmToken(userID);


  final url = 'https://fcm.googleapis.com/v1/projects/foodcatering-6bb02/messages:send';
  final accessToken = "ya29.c.c0ASRK0GaC0Ac9SLxN7jqovEcnZMrUwJNeKVkQrKkZS6BPhn4FbBMJqU5ABswdQDVQIP7cRa5NWnff0yE_6vs7EKqeYIDEMEW1AijtSnE0VA67gvU6EZKcUQ2tC3q4Di9pm9fyKLyW7Zb-cY3DQIn3DEBi98t7P7b3rgYf3fXgUrX90ugP9sVAYswsRN-d9ep3uTb11Qs1EqIFioR28N-8fbVfO9UabUmClFB7kKfloEZ-IWA-1TX2W6qRATqElDcD5c5emqrFK70fD3L6uI130IYnOpCbmbuR0m8_CXNg5HzOxjpRKGY0EcEUin53qwgmsLkCu-HEEBSnayRrJRFrZqEiz5OkxKX0gL8rxiWAl7vX8Hti2UL48NkN384Aex7Zr0Watro6YMldzIUitcRtrQJakYVQ12dId3-t6xc1mF894v0SnUpu1OcmZSwauu1q5aOc7FMkSYwo4S0ixfs_ZWk7mRirJ1RQk4kiJwmqIhSlRwcV-b_VSV0Ub63BWrkrnZwFzbdq5n_h7_oQWjdZ_Rmg0Myj0mrUMRkV0tUgtt4mU1VzY9-Ss9tnhRatJoIM71bMgOzuYQQ2uB2utl12yuwmWO3Y5w8tgW2oum0aYf_pynOqghefmBoX_IcxYJvQeFufg8zwxt45X2rQseBdcQwYmQrgUq3erdrF1WJZSt5XYS-u7tl2tgX3ufR7kY5QZJpoy9eWQ0i8BWUxykRaebkOhzjugM2auMXlzhJn7m6ggyuojOM-U4eQbgcfmZstjd3z7jiu55ejRkkmMV8xM3YorsF3Vevgyab_hqbg7_B-InOjwnvxJjIISYXfV5cxgd8g8udhb-c_606sSkSe-zcriVnodc_t10-b2Uotmb5O5BgYtwVju1xxv9Y84Bg5bQsWOvRcBlIa0W5iVvk1bxdjjw0owgFsr-Ze9Jud1xxc4xBos82VkBqhn5lv42-sxp_-1Xb680k-irS8mlygz8qo20o0jQelnbv3gzh5b50iUoUhOJ5j6Zk";

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken', // Use OAuth 2.0 token
  };

  final payload = {
    'message': {
      'token': "${fcmToken}",
      'notification': {
        'title': title,
        'body': body,
      },
      'android': {
        'notification': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
      },
      'data' : {
        'payload' : 'orderReady',
      }
    },
  };

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: json.encode(payload),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully.');
  } else {
    print('Failed to send notification: ${response.body}');
  }
}

Future<String> returnFcmToken(String userID) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(userID);
  String fcmToken = "";

  await userRef.get().then((doc) {
    fcmToken = doc.data()?['fcmToken'];
  });


  return fcmToken;
}