import 'package:flutter/material.dart';
import 'package:foodcateringwithsentimentanalysis/screens/NavigationPage.dart';

import '../reusableWidgets/reusableFunctions.dart';
import '../reusableWidgets/reusableWidgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ConfirmOrderQrScanner extends StatefulWidget {
  final int orderID;
  final String desiredPickupTime;

  const ConfirmOrderQrScanner({
    Key? key,
    required this.orderID,
    required this.desiredPickupTime,
  }) : super(key: key);

  @override
  State<ConfirmOrderQrScanner> createState() => _ConfirmOrderQrScannerState();
}

class _ConfirmOrderQrScannerState extends State<ConfirmOrderQrScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  int counter = 0;
  String username = "";
  String balance = "";

  void initState() {
    super.initState();
    counter = 0;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {

      if (scanData.code!.split(' ')[1] == widget.orderID.toString()) {
        if (counter == 0) {
          counter = 1;
          _performAction(scanData.code!.split(' ')[0]);
        } else {
          print("QR code already processed");
        }
      } else {
        print("Invalid QR code");
      }
    });
  }

  Future<void> _performAction(String uniqueID) async {
    await _showConfirmationDialog(uniqueID);
  }

  Future<void> _showConfirmationDialog(String uniqueID) async {
    username = await returnUsernameWithUniqueID(uniqueID);
    balance = await returnAmountWithUniqueID(uniqueID);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Order Confirmation"),
          content: Text("Confirm order of RM${balance} for ${username}?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                counter = 0;
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                updateAdminHistoryStatus(widget.desiredPickupTime, widget.orderID);
                updateQrCodeStatus(uniqueID);
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
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
