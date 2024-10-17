import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableFunctions.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableWidgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../reusableWidgets/reusableColor.dart';
import 'AddMenuPage.dart';
import 'EditMenuPage.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {

  List categoryItems = [];
  String firstCategory = 'Loading...';

  Map<String, dynamic> menu = {};
  Map<String, dynamic> tempmenu = {};

  bool loading = false;
  TextEditingController searchController = TextEditingController();


  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      loading = true;
      categoryItems = await getCategory();
      firstCategory = categoryItems[0];
      menu = await getMenuCategory(firstCategory);
      tempmenu = await getMenuCategory(firstCategory);

      if (mounted) {
        setState(() {
          categoryItems = categoryItems;
          menu = menu;

          loading = false;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void updateDropDown() async {
    try {
      categoryItems = await getCategory();
      menu = await getMenuCategory(firstCategory);
      tempmenu = await getMenuCategory(firstCategory);

      if (mounted) {
        setState(() {
          categoryItems = categoryItems;
          menu = menu;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> filterOrders(String query) async {
    Map<String, dynamic> filteredMenu = {};

    if (query.isEmpty) {
      filteredMenu = tempmenu;
    } else {
      menu.forEach((key, value) {
        if (key.toLowerCase().contains(query.toLowerCase())) {
          filteredMenu[key] = value;
        }
      });
    }

    if (mounted) {
      setState(() {
        menu = filteredMenu;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: selectedButtonColor,
        onPressed: () async {
          bool isRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMenuPage(),
            ),
          );

          if (isRefresh == true) {
            setState(() {
              fetchData();
            });
          }
        },
        child: Icon(Icons.add,
        color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ReusableAppBar(title: "Menu", backButton: false),
            SizedBox(height: MediaQuery.of(context).size.width * 0.01),
            Container(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Search by Menu",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.only(right: 48), // Ensures the text doesn't overlap the button
                    ),
                    onChanged: (value) {
                      setState(() {
                        filterOrders(value);
                      });
                    },
                  ),
                  Positioned(
                    right: 0,
                    child: PopupMenuButton(
                      icon: Icon(Icons.filter_list),  // The filter icon
                      onSelected: (value) {
                        setState(() {
                          firstCategory = value.toString();
                          updateDropDown();  // Handle the dropdown update
                        });
                      },
                      itemBuilder: (context) => categoryItems.map((e) {
                        return PopupMenuItem(
                          value: e,
                          child: Text(e),
                        );
                      }).toList(),
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width * 0.01),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "Showing all menu for $firstCategory...",
                  style: GoogleFonts.lato(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [

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

                  if (menu.isEmpty && !loading)
                    Center(
                      child: Text(
                        "No menu available",
                        style: GoogleFonts.lato(
                          fontSize: MediaQuery.of(context).size.width * 0.06,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                    ),

                  if (menu.isNotEmpty && !loading)
                  for (var item in menu.entries)
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: lightGrey,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  FutureBuilder(
                                    future: getMenuImage(item.value['imageURL']),
                                    builder: (context, snapshot) {
                                      return CachedNetworkImage(
                                        imageUrl: snapshot.data.toString(),
                                        imageBuilder: (context, imageProvider) => Container(
                                          width: MediaQuery.of(context).size.width * 0.3,
                                          height: MediaQuery.of(context).size.width * 0.3,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                            ),
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
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:[
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.611,
                                      child: Row(
                                        children: [
                                          Text(
                                            item.key,
                                            style: GoogleFonts.lato(
                                              fontSize: MediaQuery.of(context).size.width * 0.06,
                                              fontWeight: FontWeight.bold,
                                            )
                                          ),
                                          Spacer(),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.1,
                                            height: MediaQuery.of(context).size.width * 0.1,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                                onPressed: () async {
                                                  bool isRefresh = await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => EditMenuPage(menuItem: item),
                                                    ),
                                                  );

                                                  if (isRefresh == true) {
                                                    setState(() {
                                                      fetchData();
                                                    });
                                                  }
                                                },
                                                icon: Icon(Icons.edit,),
                                                iconSize: MediaQuery.of(context).size.width * 0.05,
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.1,
                                            height: MediaQuery.of(context).size.width * 0.1,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              onPressed: () async {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: Text("Delete Menu"),
                                                      content: Text("Are you sure you want to delete this menu?"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text("Cancel"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                            deleteMenu(item.value['imageURL']);
                                                            setState(() {
                                                              updateDropDown();
                                                            });
                                                          },
                                                          child: Text("Delete",
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                );
                                              },
                                              icon: Icon(Icons.delete,),
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                        "RM ${item.value['price'].toString()}",
                                      style: GoogleFonts.lato(
                                        fontSize: MediaQuery.of(context).size.width * 0.035,
                                        color: Colors.green,
                                      )
                                    ),
                                    IgnorePointer(
                                      ignoring: true,
                                      child: RatingBar.builder(
                                        itemSize: MediaQuery.of(context).size.width * 0.04,
                                        initialRating: (item.value['rating'] as num).toDouble(),
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (rating) {
                                          print(rating);
                                        },
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                            "${(item.value['rating']).toStringAsFixed(2)}",
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width * 0.035,
                                                color: Colors.amber[700])
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width * 0.005),
                                        Text(
                                            "(${(item.value['totalUsersRating'])})",
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width * 0.035,
                                                color: Colors.grey)
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.6,
                                      child: Text(
                                        wordLimit(item.value['description'], 50),
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.height * 0.02,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,  // Use ellipsis for overflow
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        ),
                        SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                      ],
                    )
                ],
              ),
            ),
          ]
        ),
      )
    );
  }
}
