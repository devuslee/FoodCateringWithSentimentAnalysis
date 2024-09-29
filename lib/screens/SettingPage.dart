import 'package:flutter/material.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableWidgets.dart';
import 'package:foodcateringwithsentimentanalysis/screens/QrCodeScanner.dart';

import '../reusableWidgets/reusableFunctions.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      // Fetch data here
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
            ReusableAppBar(title: "Settings", backButton: false),
            SizedBox(height: MediaQuery.of(context).size.width * 0.01),
            ReuseableSettingContainer(
              title: "Top Up",
              icon: Icons.attach_money,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QrCodeScanner())
                );
              },
            ),
            ReuseableSettingContainer(
              title: "Log Out",
              icon: Icons.attach_money,
              onTap: () {
                logout(context);
              },
            ),
          ],
        ),
      )
    );
  }
}
