import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:huggingface_dart/huggingface_dart.dart';
import 'package:intl/intl.dart';
import 'package:vertical_barchart/vertical-barchartmodel.dart';

import '../screens/AnalysisPage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
HfInference hfInference = HfInference('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');



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

Future<Map<String, List<Map<String, dynamic>>>> returnAllReviews(String timeRange) async {
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


  for (var item in menu) {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(item);

    //test code
    await reviewRef.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
        if (createdAt.isAfter(startDate) && createdAt.isBefore(DateTime.now())) {
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

Future<double> returnRating(String timeRange) async {
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


  for (var item in menu) {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(item);

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

Future<int> returnTotalReview(String timeRange) async {
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

  for (var item in menu) {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(item);

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

Future<double> returnSale(String timeRange) async {
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

  for (var i = 0; i < dayGap; i++) {
    final orderRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('orders')
        .collection(DateTime.now().subtract(Duration(days: i)).toString().split(' ')[0]);

    await orderRef.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
          totalSale = totalSale + doc.data()['total'];

      });
    });
  }

  return totalSale;
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
      if (doc.data()['status'] == 'Completed') {
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

Future<Map<String, int>> returnSentiment(String timeRange) async {
  Map<String, int> sentimentCount = {
    'positive': 0,
    'negative': 0,
    'neutral': 0,
  };
  List menu = await getMenu();
  double positive = 0;
  double negative = 0;
  double neutral = 0;

  double highest = 0;
  String comment = '';
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
    startDate = DateTime(2021, 1, 1);
  } else {
    startDate = DateTime.now();
  }


  for (var item in menu) {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(item);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
      if (createdAt.isAfter(startDate) && createdAt.isBefore(DateTime.now())) {
        positive = doc.data()?['positive'];
        neutral = doc.data()?['neutral'];
        negative = doc.data()?['negative'];
        highest = max(positive, max(neutral, negative));
        if (highest == positive) {
          comment = 'positive';
        } else if (highest == neutral) {
          comment = 'neutral';
        } else if (highest == negative) {
          comment = 'negative';
        }
        if (comment == 'positive') {
          sentimentCount['positive'] = (sentimentCount['positive'] ?? 0) + 1;
        } else if (comment == 'negative') {
          sentimentCount['negative'] = (sentimentCount['negative'] ?? 0) + 1;
        } else if (comment == 'neutral') {
          sentimentCount['neutral'] = (sentimentCount['neutral'] ?? 0) + 1;
        }
      }
    }
  }

  return sentimentCount;
}

Future<List<Map>> returnWordCloud(String timeRange) async {
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


  for (var item in menu) {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(item);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
      if (createdAt.isAfter(startDate) && createdAt.isBefore(DateTime.now())) {
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

Future<int> returnWordCloudCounter(String timeRange) async {
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


  for (var item in menu) {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(item);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
      if (createdAt.isAfter(startDate) && createdAt.isBefore(DateTime.now())) {
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


Future<List<VBarChartModel>> returnBarData(String timeRange) async {
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


  for (var item in menu) {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(item);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
      if (createdAt.isAfter(startDate) && createdAt.isBefore(DateTime.now())) {
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

Future<List<VBarChartModel>> returnMenuRating(String timeRange) async {
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


  for (var item in menu) {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(item);

    final querySnapshot = await reviewRef.get();

    for (var doc in querySnapshot.docs) {
      DateTime createdAt = DateTime.parse(doc.data()?['createdAt']);
      if (createdAt.isAfter(startDate) && createdAt.isBefore(DateTime.now())) {
        totalRating[item] = (totalRating[item] ?? 0) + doc.data()?['rating'];
        totalCounter[item] = (totalCounter[item] ?? 0) + 1;
      }
    }

    if (totalCounter[item] != null && totalCounter[item]! > 0) {
      averageRating[item] = totalRating[item]! / totalCounter[item]!;
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
