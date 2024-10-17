import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableColor.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableWidgets.dart';
import 'package:google_fonts/google_fonts.dart';

import '../reusableWidgets/reusableFunctions.dart';
import 'ConfirmOrderQrScanner.dart';
import 'package:google_fonts/google_fonts.dart';

import 'OrderSummary.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List orders = [];
  List filteredOrders = [];

  int totalmeals = 0;
  int totalcompletedorders = 0;
  int totalordersLeft = 0;

  String totalOrders = "";
  String selectedDateTime = DateTime.now().toString().split(" ")[0];

  DateTime selectedDate = DateTime.now();

  List<bool> isSelected = [true, false];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();

  }

  void fetchData() async {
    try {
      orders = await returnAllOrders(selectedDateTime);
      totalmeals = await getTotalMeals(selectedDateTime);
      totalcompletedorders = await getTotalCompletedOrders(selectedDateTime);
      totalordersLeft = await getTotalPendingOrders(selectedDateTime);


      if (mounted) {
        setState(() {
          orders = orders;
          totalOrders = orders.length.toString();
          filteredOrders = orders;
          totalmeals = totalmeals;
          totalcompletedorders = totalcompletedorders;
          totalordersLeft = totalordersLeft;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> filterOrders(String query) async {
    List filtered = [];
    if (query.isEmpty) {
      filtered = orders;
    } else {
      for (var order in orders) {
        String tempUsername = await getUsername(order['userID']);
        if (tempUsername.toLowerCase().contains(query.toLowerCase())) {
          filtered.add(order);
        }
      }
    }

    setState(() {
      filteredOrders = filtered;
    });
  }

  void _incrementDate() {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: 1));
      selectedDateTime = selectedDate.toString().split(" ")[0];
      setState(() {
        fetchData();
      });
    });
  }

  void _decrementDate() {
    setState(() {
      selectedDate = selectedDate.subtract(Duration(days: 1));
      selectedDateTime = selectedDate.toString().split(" ")[0];
      setState(() {
        fetchData();
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ReusableAppBar(title: "Home Page", backButton: false),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _decrementDate,
                  icon: Icon(
                    Icons.arrow_left,
                    size: MediaQuery.of(context).size.width * 0.15,
                    color: selectedButtonColor,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(selectedDateTime),
                      firstDate: DateTime(2021),
                      lastDate: DateTime(2025),
                    );

                    if (date != null) {
                      selectedDate = date;
                      selectedDateTime = date.toString().split(" ")[0];
                      setState(() {
                        fetchData();
                      });
                    }
                  },
                  child: Text(
                    DayMonthYearFormatter(selectedDateTime),
                    style: GoogleFonts.lato(
                      fontSize: MediaQuery.of(context).size.width * 0.065, // Adjust font size
                      fontWeight: FontWeight.bold, // Adjust font weight
                      color: selectedButtonColor, // Adjust text color
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _incrementDate,
                  icon: Icon(
                    Icons.arrow_right,
                    size: MediaQuery.of(context).size.width * 0.15,
                    color: selectedButtonColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: lightGrey,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Column(
                          children: [
                            Text("Total Orders:",
                              style: GoogleFonts.lato(
                                fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                                fontWeight: FontWeight.bold, // Adjust font weight
                                color: selectedButtonColor, // Adjust text color
                              ),
                            ),
                            Text(totalordersLeft.toString(), style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.1, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: MediaQuery.of(context).size.height * 0.145,
                        color: Colors.grey,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Column(
                          children: [
                            Text("Completed:", style: GoogleFonts.lato(
                              fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                              fontWeight: FontWeight.bold, // Adjust font weight
                              color: selectedButtonColor, // Adjust text color
                            ),),
                            Text(totalcompletedorders.toString(), style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.1, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: MediaQuery.of(context).size.height * 0.145,
                        color: Colors.grey,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Column(
                          children: [
                            Text("Total Meals:",
                                style: GoogleFonts.lato(
                              fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                              fontWeight: FontWeight.bold, // Adjust font weight
                              color: selectedButtonColor, // Adjust text color
                            ),),
                            Text(totalmeals.toString(), style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.1, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 1,
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderSummary(
                            order: orders,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.05,
                      color: Colors.grey[300],
                      child: Center(
                        child: Text("View Order Summary",
                          style: GoogleFonts.lato(
                            fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                            fontWeight: FontWeight.bold, // Adjust font weight
                            color: selectedButtonColor, // Adjust text color
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            // Text("Orders Today", style: GoogleFonts.lato(
            //   fontSize: MediaQuery.of(context).size.width * 0.05, // Adjust font size
            //   fontWeight: FontWeight.bold, // Adjust font weight
            //   color: selectedButtonColor, // Adjust text color
            // ),),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
              width : MediaQuery.of(context).size.width * 0.9,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Search by Name",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  filterOrders(value);
                },
              ),
            ),
            if (filteredOrders.isEmpty)
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Icon(Icons.hourglass_empty, size: MediaQuery.of(context).size.width * 0.2, color: selectedButtonColor),
                    Text("No Orders Found",
                      style: GoogleFonts.lato(
                        fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                        fontWeight: FontWeight.bold, // Adjust font weight
                        color: selectedButtonColor, // Adjust text color
                      ),
                    ),
                  ],
                ),
              ),

            if (filteredOrders.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    // border: Border(
                    //   bottom: BorderSide(color: Colors.grey),
                    //   top: index == 0 ? BorderSide(color: Colors.grey) : BorderSide(color: Colors.white),
                    // ),
                  ),
                  child: ExpansionTile(
                    title: FutureBuilder(
                      future: getUsername(filteredOrders[index]['userID']),
                      builder: (context, snapshot) {
                        return Text("User: ${snapshot.data}",
                        style: GoogleFonts.lato(
                          fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                          fontWeight: FontWeight.bold, // Adjust font weight
                          color: selectedButtonColor, // Adjust text color
                          ),);
                      },
                    ),
                    subtitle: Text("Order ID: ${filteredOrders[index]['id']}",
                    style: GoogleFonts.lato(
                      fontSize: MediaQuery.of(context).size.width * 0.03, // Adjust font size
                      color: Colors.grey, // Adjust text color
                      ),
                    ),
                    trailing: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: ElevatedButton(
                        onPressed: filteredOrders[index]['status'] == 'Completed and Reviewed' ? () {}
                            : filteredOrders[index]['status'] == 'Completed' ? () {} : () {
                          if (filteredOrders[index]['status'] == "Pending") {
                            updateOrderStatus(filteredOrders[index]['id'].toString(), filteredOrders[index]['userID'].toString(), "Ready", selectedDateTime);
                            sendNotification("Order is Ready", "Your order is ready for pickup", filteredOrders[index]['userID'].toString());
                            setState(() {
                              filteredOrders[index]['status'] = "Ready";
                            });
                          }
                          else if (filteredOrders[index]['status'] == "Ready") {
                            updateOrderStatus(filteredOrders[index]['id'].toString(), filteredOrders[index]['userID'].toString(), "Pending", selectedDateTime);
                            setState(() {
                              filteredOrders[index]['status'] = "Pending";
                            });
                          }
                        },
                        child: Text(filteredOrders[index]['status'] == "Completed and Reviewed" ? "Reviewed" : filteredOrders[index]['status'],
                          style: GoogleFonts.lato(
                            fontSize: MediaQuery.of(context).size.width * 0.035, // Adjust font size
                            fontWeight: FontWeight.bold, // Adjust font weight
                            color: selectedButtonColor, // Adjust text color
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: filteredOrders[index]['status'] == "Pending"
                              ? Colors.yellow
                              : filteredOrders[index]['status'] == "Ready" ?
                              Colors.green : Colors.grey[300],
                          side: BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                        ),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Pickup Time: ${HourFormatter(filteredOrders[index]['desiredPickupTime'])}",
                                    style: GoogleFonts.lato(
                                      fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                                      color: selectedButtonColor, // Adjust text color
                                      ),
                                    ),
                                    Text("Payment Method: ${filteredOrders[index]['paymentMethod']}",
                                      style: GoogleFonts.lato(
                                        fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                                        color: selectedButtonColor, // Adjust text color
                                      ),
                                    ),
                                    Text("Total: RM${filteredOrders[index]['total']}",
                                      style: GoogleFonts.lato(
                                        fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                                        color: selectedButtonColor, // Adjust text color
                                      ),
                                    ),
                                    if (filteredOrders[index]['specialRemarks'] != "")
                                      Text("Special Remarks: ${filteredOrders[index]['specialRemarks']}",
                                        style: GoogleFonts.lato(
                                          fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                                          color: selectedButtonColor, // Adjust text color
                                        ),
                                      ),
                                  ],
                                ),
                                if (filteredOrders[index]['status'] == "Ready")
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          bool isRefresh = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ConfirmOrderQrScanner(
                                                orderID: filteredOrders[index]['id'],
                                                desiredPickupTime: filteredOrders[index]['desiredPickupTime'],
                                              ),
                                            ),
                                          );

                                          if (isRefresh) {
                                            setState(() {
                                              fetchData();
                                            });
                                          }
                                        },
                                        icon: Icon(Icons.qr_code,
                                        size: MediaQuery.of(context).size.width * 0.1,
                                      ),
                                      ),
                                      Text("Scan QR Code",
                                        style: GoogleFonts.lato(
                                          fontSize: MediaQuery.of(context).size.width * 0.03, // Adjust font size
                                          color: Colors.grey, // Adjust text color
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            Divider(),
                            Center(
                              child: Text("Order",
                              style: GoogleFonts.lato(
                                fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                                fontWeight: FontWeight.bold, // Adjust font weight
                                color: selectedButtonColor, // Adjust text color
                                ),
                              ),
                            ),
                            for (var i = 0; i < filteredOrders[index]['orderHistory'].length; i++)
                              Row(
                                children: [
                                  Text("${filteredOrders[index]['orderHistory'][i]['name']}",
                                  style: GoogleFonts.lato(
                                    fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                                    color: selectedButtonColor, // Adjust text color
                                    ),
                                  ),
                                  Spacer(),
                                  Text("${filteredOrders[index]['orderHistory'][i]['quantity']}",
                                  style: GoogleFonts.lato(
                                    fontSize: MediaQuery.of(context).size.width * 0.04, // Adjust font size
                                    color: selectedButtonColor, // Adjust text color
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      )
    );
  }
}
