import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:foodcateringwithsentimentanalysis/screens/AnalysisPage.dart';
import 'package:foodcateringwithsentimentanalysis/screens/HomePage.dart';
import 'package:foodcateringwithsentimentanalysis/screens/MenuPage.dart';
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
      Placeholder(),
    ];
  }

  final IconList = [
    Icons.home,
    Icons.redeem,
    Icons.menu,
    Icons.person,
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[currentPageIndex],
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        height: 80,
        itemCount: IconList.length,
        tabBuilder: (index, isActive) {
          final color = isActive ? Colors.blue : Colors.grey;
          return Container(
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconBadge(
                      icon: Icon(IconList[index], color: color, size: 30,),
                      itemCount: 0,
                      badgeColor: Colors.red,
                      right: 6,
                      top: 0,
                      hideZero: true,
                      itemColor: Colors.white,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        index == 0 ? 'Home' : index == 1 ? 'Analysis' : index == 2 ? 'Menu' : index == 3 ? 'Profile' : '',
                        maxLines: 1,
                        style: TextStyle(color: color),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        activeIndex: currentPageIndex,
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.defaultEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => setState(() => currentPageIndex = index),
      ),
    );
  }
}
