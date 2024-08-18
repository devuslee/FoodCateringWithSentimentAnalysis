import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableFunctions.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableWidgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

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


  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      categoryItems = await getCategory();
      firstCategory = categoryItems[0];
      menu = await getMenuCategory(firstCategory);

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

  void updateDropDown() async {
    try {
      categoryItems = await getCategory();
      menu = await getMenuCategory(firstCategory);

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ReusableAppBar(title: "Menu", backButton: false),
            SizedBox(height: MediaQuery.of(context).size.width * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  DropdownButton(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
                    value: firstCategory,
                    items: categoryItems.map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
                    onChanged: (value) {
                      setState(() {
                        firstCategory = value.toString();
                        updateDropDown();
                      });
                    },
                  ),
                  IconButton(
                      onPressed: () {
                        updateDropDown();
                      },
                      icon: Icon(Icons.refresh)
                  ),
                  Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
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
                      icon: Icon(Icons.add),
                      color: Colors.green,
                    )
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  for (var item in menu.entries)
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
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
                                          width: MediaQuery.of(context).size.width * 0.2,
                                          height: MediaQuery.of(context).size.width * 0.2,
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
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:[
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.75,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.key,
                                            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03, fontWeight: FontWeight.bold
                                            )
                                          ),
                                          Spacer(),
                                          IconButton(
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
                                              icon: Icon(Icons.edit),
                                          ),
                                          IconButton(
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
                                            icon: Icon(Icons.delete),
                                            color: Colors.red,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                        "RM ${item.value['price'].toString()}",
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.015,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                            "${(item.value['rating']).toStringAsFixed(2)}",
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width * 0.02,
                                                color: Colors.amber)
                                        ),
                                        IgnorePointer(
                                          ignoring: true,
                                          child: RatingBar.builder(
                                            itemSize: MediaQuery.of(context).size.width * 0.0225,
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
                                        Text(
                                            "(${(item.value['totalUsersRating'])})",
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context).size.width * 0.02,
                                                color: Colors.grey)
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.75,
                                      child: Text(
                                        wordLimit(item.value['description'], 50),
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.height * 0.02,
                                        ),
                                        maxLines: null,
                                        overflow: TextOverflow.visible,
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        ),
                        SizedBox(height: MediaQuery.of(context).size.width * 0.01),
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
