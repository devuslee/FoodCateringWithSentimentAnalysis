import 'package:flutter/material.dart';
import 'package:foodcateringwithsentimentanalysis/screens/NavigationPage.dart';

import '../reusableWidgets/reusableFunctions.dart';
import '../reusableWidgets/reusableWidgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({super.key});

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  final String expectedQRData = "0123456789";

  int counter = 0;
  String username = "";
  double balance = 0;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code?.split(' ')[0] == expectedQRData) {
        _performAction(scanData.code!.split(' ')[1], scanData.code!.split(' ')[2], scanData.code!.split(' ')[3]);
      } else {
        print("Invalid QR code");
      }
    });
  }

  Future<void> _performAction(String userID, String amount, String uniqueID) async {
    username = await returnUsernameWithID(userID);
    balance = await returnBalanceWithID(userID);
    if (counter == 0) {
      counter = 1;
      _showConfirmationDialog(userID, double.parse(amount), username, balance, uniqueID);
    }
  }

  void _showConfirmationDialog(String userID, double amount, String username, double balance, String uniqueID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Topup Wallet"),
          content: Text("User Detected: ${username}\nCurrent Balance: ${balance.toString()}\nTopup Amount: ${amount}\nNew Balance: ${balance + amount}"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                TopupUserWallet(userID, amount);
                updateQrCodeStatus(uniqueID);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ReusableAppBar(title: "QR Code Scanner", backButton: true),
          SizedBox(height: MediaQuery.of(context).size.width * 0.01),
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.8,
            width: MediaQuery.of(context).size.width * 0.8,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 100,
                borderWidth: 100,
                cutOutSize: 300.0,
              ),
            ),
          ),
        ],
      )
    );
  }
}
