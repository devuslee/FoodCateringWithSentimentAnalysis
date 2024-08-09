import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


Future<List<Map<String, dynamic>>> returnAllOrders() async {
  List<Map<String, dynamic>> orders = [];

  final orderRef = FirebaseFirestore.instance
      .collection('admin')
      .doc('orders')
      .collection(DateTime.now().toString().split(' ')[0]);

  await orderRef.get().then((querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      orders.add(doc.data());
    });
  });

  return orders;
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