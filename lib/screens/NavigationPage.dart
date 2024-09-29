import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableColor.dart';
import 'package:foodcateringwithsentimentanalysis/screens/AnalysisPage.dart';
import 'package:foodcateringwithsentimentanalysis/screens/HomePage.dart';
import 'package:foodcateringwithsentimentanalysis/screens/MenuPage.dart';
import 'package:foodcateringwithsentimentanalysis/screens/SettingPage.dart';
import 'package:icon_badge/icon_badge.dart';


class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int currentPageIndex = 0;
  late List<Widget> _pages;

  void initState() {
    super.initState();
    _pages = _initializePages(); // Initialize _pages after setting redeemPageIndex
    fetchData();
  }

  void fetchData() async {
    try {
      setState(() {
        _pages = _initializePages(); // Update _pages after fetching data
      });
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  List<Widget> _initializePages() {
    return [
      HomePage(),
      AnalysisPage(),
      MenuPage(),
      SettingPage(),
    ];
  }

  final IconList = [
    Icons.home,
    Icons.redeem,
    Icons.menu,
    Icons.settings,
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[currentPageIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 1,  // Thin line
            decoration: BoxDecoration(
              color: Colors.grey[300],  // Light grey color for the line
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,  // Light shadow
                  blurRadius: 6,  // How much the shadow spreads
                  offset: Offset(0, -3),  // Position of shadow (above the line)
                ),
              ],
            ),
          ),
          BottomAppBar(
            padding: EdgeInsets.symmetric(horizontal: 0),
            height: MediaQuery.of(context).size.height * 0.1,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.8 / IconList.length,
                  child: InkWell(
                    onTap: () => setState(() => currentPageIndex = 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home,
                          color: currentPageIndex == 0 ? selectedButtonColor : notSelectedButtonColor,
                          size: MediaQuery.of(context).size.height * 0.04,
                        ),
                        Text(
                          "Home",
                          maxLines: 1,
                          style: TextStyle(color: currentPageIndex == 0 ? selectedButtonColor : notSelectedButtonColor,
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8 / IconList.length,
                  child: InkWell(
                    onTap: () => setState(() => currentPageIndex = 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.redeem,
                          color: currentPageIndex == 1 ? selectedButtonColor : notSelectedButtonColor,
                          size: MediaQuery.of(context).size.height * 0.04,
                        ),
                        Text(
                          "Redeem",
                          maxLines: 1,
                          style: TextStyle(color: currentPageIndex == 1 ? selectedButtonColor : notSelectedButtonColor,
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8 / IconList.length,
                  child: InkWell(
                    onTap: () => setState(() => currentPageIndex = 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: currentPageIndex == 2 ? selectedButtonColor : notSelectedButtonColor,
                          size: MediaQuery.of(context).size.height * 0.04,
                        ),
                        Text(
                          "Order",
                          maxLines: 1,
                          style: TextStyle(color: currentPageIndex == 2 ? selectedButtonColor : notSelectedButtonColor,
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8 / IconList.length,
                  child: InkWell(
                    onTap: () => setState(() => currentPageIndex = 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          color: currentPageIndex == 3 ? selectedButtonColor : notSelectedButtonColor,
                          size: MediaQuery.of(context).size.height * 0.04,
                        ),
                        Text(
                          "History",
                          maxLines: 1,
                          style: TextStyle(color: currentPageIndex == 3 ? selectedButtonColor : notSelectedButtonColor,
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}