import 'package:flutter/material.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableColor.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableWidgets.dart';
import 'package:google_fonts/google_fonts.dart';


class OrderSummary extends StatefulWidget {
  final List order;

  const OrderSummary({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  Map<String, int> pendingOrderItems = {};
  Map<String, int> completedOrderItems = {};

  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      if (widget.order.isEmpty) {
        return;
      }

      for (int i = 0; i < widget.order.length; i++) {
        List<dynamic> itemName = widget.order[i]['orderHistory'];
        String status = widget.order[i]['status'];

        if (status == "Pending") {
          for (var item in itemName) {
            int quantity = item['quantity'];
            if (pendingOrderItems.containsKey(item['name'])) {
              pendingOrderItems[item['name']] = pendingOrderItems[item['name']]! + quantity; // Increment the existing quantity
            } else {
              pendingOrderItems[item['name']] = quantity; // Initialize with the current quantity
            }
          }
        }


        if (status == "Completed" || status == "Completed and Reviewed" || status == "Ready") {
          for (var item in itemName) {
            int quantity = item['quantity'];
            if (completedOrderItems.containsKey(item['name'])) {
              completedOrderItems[item['name']] = completedOrderItems[item['name']]! + quantity; // Increment the existing quantity
            } else {
              completedOrderItems[item['name']] = quantity; // Initialize with the current quantity
            }
          }
        }
      }



      if (mounted) {
        setState(() {

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
            ReusableAppBar(title: "Order Summary", backButton: true),
            SizedBox(height: MediaQuery.of(context).size.width * 0.01),


            if (widget.order.isEmpty)
              Center(
                child: Text("No orders found",
                  style: GoogleFonts.lato(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: selectedButtonColor,
                  ),
                ),
              )

            else
            Column(
              children: [
                Text("${widget.order[0]['desiredPickupTime'].toString().split(' ')[0]}",
                  style: GoogleFonts.lato(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: selectedButtonColor,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pendingOrderItems.isNotEmpty)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text("Pending Orders",
                            style: GoogleFonts.lato(
                              fontSize: MediaQuery.of(context).size.width * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow[800],
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.width * 0.01),
                          Divider(
                            height: 1,
                            thickness: 2,
                            color: Colors.grey,
                          ),
                          for (var item in pendingOrderItems.entries)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${item.key}",
                                    style: GoogleFonts.lato(
                                      fontSize: MediaQuery.of(context).size.width * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: selectedButtonColor,
                                    ),
                                  ),
                                  Spacer(),
                                  Text("${item.value}",
                                    style: GoogleFonts.lato(
                                      fontSize: MediaQuery.of(context).size.width * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: selectedButtonColor,
                                    ),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.width * 0.01),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text("Completed Orders",
                            style: GoogleFonts.lato(
                              fontSize: MediaQuery.of(context).size.width * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.width * 0.01),
                          Divider(
                            height: 1,
                            thickness: 2,
                            color: Colors.grey,
                          ),
                          for (var item in completedOrderItems.entries)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${item.key}",
                                    style: GoogleFonts.lato(
                                      fontSize: MediaQuery.of(context).size.width * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: selectedButtonColor,
                                    ),
                                  ),
                                  Spacer(),
                                  Text("${item.value}",
                                    style: GoogleFonts.lato(
                                      fontSize: MediaQuery.of(context).size.width * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: selectedButtonColor,
                                    ),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.width * 0.01),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if(pendingOrderItems.isEmpty && completedOrderItems.isNotEmpty)
                  Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.width * 0.1),
                      Text("You have completed all orders!",
                        style: GoogleFonts.lato(
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          fontWeight: FontWeight.bold,
                          color: selectedButtonColor,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      )
    );
  }
}
