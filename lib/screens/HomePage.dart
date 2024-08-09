import 'package:flutter/material.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableWidgets.dart';

import '../reusableWidgets/reusableFunctions.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List orders = [];

  int totalmeals = 0;
  int totalcompletedorders = 0;
  int totalordersLeft = 0;

  String totalOrders = "";
  List<bool> isSelected = [true, false];

  @override
  void initState() {
    super.initState();
    fetchData();

  }

  void fetchData() async {
    try {
      orders = await returnAllOrders();
      totalmeals = await getTotalMeals();
      totalcompletedorders = await getTotalCompletedOrders();
      totalordersLeft = await getTotalPendingOrders();


      setState(() {
        orders = orders;
        totalOrders = orders.length.toString();
        totalmeals = totalmeals;
        totalcompletedorders = totalcompletedorders;
        totalordersLeft = totalordersLeft;
      });

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
            ReusableAppBar(title: "Home Page", backButton: false),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: Column(
                            children: [
                              Text("Total Orders:", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.025),),
                              Text(totalordersLeft.toString(), style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.1, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: MediaQuery.of(context).size.height * 0.2,
                          color: Colors.grey,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: Column(
                            children: [
                              Text("Completed:", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.025),),
                              Text(totalcompletedorders.toString(), style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.1, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: MediaQuery.of(context).size.height * 0.2,
                          color: Colors.grey,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: Column(
                            children: [
                              Text("Total Meals:", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.025),),
                              Text(totalmeals.toString(), style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.1, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
        
                  ],
                )
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                orders[index]['isExpanded'] = false;
                return Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey),
                      top: index == 0 ? BorderSide(color: Colors.grey) : BorderSide(color: Colors.white),
                    )
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder(
                                future: getUsername(orders[index]['userID']),
                                builder: (context, snapshot) {
                                  return Text("User: ${snapshot.data.toString()}");
                                }
                                ),
                            Text("Order ID: ${orders[index]['id']}"),
                          ]
                      ),
                      Spacer(),
                      ElevatedButton(
                          onPressed: (){
                            updateOrderStatus(orders[index]['id'].toString(), orders[index]['userID'].toString(), "Pending");
                            setState(() {
                              orders[index]['status'] = "Pending";
                            });
                          },
                          child: Text("Pending"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orders[index]['status'] == "Pending" ? Colors.yellow : Colors.white,
                            side: BorderSide(
                              color: Colors.grey,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                          )
                      ),
                      ElevatedButton(
                          onPressed: (){
                            updateOrderStatus(orders[index]['id'].toString(), orders[index]['userID'].toString(), "Completed");
                            setState(() {
                              orders[index]['status'] = "Completed";
                            });
                          },
                          child: Text("Ready"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orders[index]['status'] == "Completed" ? Colors.green : Colors.white,
                            side: BorderSide(
                              color: Colors.grey,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                          )
                      ),
                      IconButton(
                        icon: Icon(orders[index]['isExpanded']
                            ? Icons.expand_less
                            : Icons.expand_more),
                        onPressed: () {
                          setState(() {
                            if (orders[index]['isExpanded'] == true)
                              orders[index]['isExpanded'] = false;
                            else
                              orders[index]['isExpanded'] = true;
                          });
                        },
                      ),
                    ],
                  ),
                );
              }
            )

        
        
          ],
        ),
      )
    );
  }
}
