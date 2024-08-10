import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
final FirebaseStorage _storage = FirebaseStorage.instance;




Future<List<Map<String, dynamic>>> returnAllOrders() async {
  List<Map<String, dynamic>> orders = [];

  //actual code
  final orderRef = FirebaseFirestore.instance
      .collection('admin')
      .doc('orders')
      .collection(DateTime.now().toString().split(' ')[0]);


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

Future<double> returnTodayRating() async {
  double totalRating = 0;
  double counter = 0;
  double averageRating = 0;
  List menu = await getMenu();


  for (var item in menu) {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(item);

    await reviewRef.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc.data()?['createdAt'].toString().split(' ')[0] == DateTime.now().toString().split(' ')[0]) {
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

Future<int> returnTodayTotalReview() async {
  int totalReviews = 0;
  List menu = await getMenu();


  for (var item in menu) {
    final reviewRef = FirebaseFirestore.instance
        .collection('admin')
        .doc('reviews')
        .collection(item);

    await reviewRef.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc.data()?['createdAt'].toString().split(' ')[0] == DateTime.now().toString().split(' ')[0]) {
          totalReviews = totalReviews + 1;
        }
      });
    });
  }


  return totalReviews;
}

Future<double> returnTodaySale() async {
  double totalSale = 0;

  //actual code
  // final orderRef = FirebaseFirestore.instance
  //     .collection('admin')
  //     .doc('orders')
  //     .collection(DateTime.now().toString().split(' ')[0]);


  final orderRef = FirebaseFirestore.instance
      .collection('admin')
      .doc('orders')
      .collection("2024-08-09");


  await orderRef.get().then((querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      totalSale = totalSale + doc.data()['total'];
    });
  });

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

Future<int> getTotalMeals() async {
  int totalMeals = 0;

  final orderRef = FirebaseFirestore.instance
      .collection('admin')
      .doc('orders')
      .collection(DateTime.now().toString().split(' ')[0]);

  await orderRef.get().then((querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      totalMeals = totalMeals + int.parse(doc.data()['orderHistory'].length.toString());
      // totalMeals = totalMeals + doc.data()['orderHistory'].length;
    });
  });


  return totalMeals;
}

Future<int> getTotalCompletedOrders() async {
  int totalOrders = 0;

  final orderRef = FirebaseFirestore.instance
      .collection('admin')
      .doc('orders')
      .collection(DateTime.now().toString().split(' ')[0]);

  await orderRef.get().then((querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      if (doc.data()['status'] == 'Completed') {
        totalOrders = totalOrders + 1;
      }
    });
  });


  return totalOrders;
}


Future<int> getTotalPendingOrders() async {
  int pendingOrders = 0;

  final orderRef = FirebaseFirestore.instance
      .collection('admin')
      .doc('orders')
      .collection(DateTime.now().toString().split(' ')[0]);

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



void updateOrderStatus(String orderID, String userID, String status) async {

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
      .collection(DateTime.now().toString().split(' ')[0])
      .doc(orderID);

   userRef.update({
    'status': status,
  });

   adminRef.update({
    'status': status,
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

