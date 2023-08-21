//import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inuachama/models/billmodel.dart';
import 'package:inuachama/util/configurations.dart';
import 'package:inuachama/util/templates.dart';
import 'package:http/http.dart' as http;

late BuildContext con;
late String title;
late ScaffoldMessengerState scaffoldMessenger;

class Billing extends StatefulWidget {
  const Billing({Key? key}) : super(key: key);

  @override
  BillingState createState() => BillingState();
}

class BillingState extends State<Billing> {
  List<Bill> bills = [];
  List<Bill> allBills = [];
  String query = "";
  String userGroupCode = "";
  bool loadingBills = true;
  final Prefs _prefs = Prefs();
  TextEditingController filterController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController mpesacodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getClickedGroupDetails();
  }

  void getClickedGroupDetails() {
    _prefs.getClickedGroup().then((group) => {
          setState(() => {
                userGroupCode = group.groupCode,
                _populateTransactions(),
              })
        });
  }

  void _populateTransactions() {
    filterController.clear();
    bills.clear();
    allBills.clear();

    Webservice()
        .load(Bill.all("getbills.php?groupCode=$userGroupCode"))
        .then((mybills) => {
              setState(() =>
                  {allBills = mybills, bills = allBills, loadingBills = false})
            });
  }

  Widget _buildItemsForListView(BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      shadowColor: priColor,
      borderOnForeground: false,
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 30,
                  backgroundColor: priAccentColor,
                  child: const Icon(
                    Icons.payment,
                    color: secbgColor,
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${bills[index].billReason}",
                        style: widgetTitleText(),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Generated: ${DateFormatter().getVerboseDateTimeRepresentation(myDateFormartted(bills[index].createdDate.toString()))}",
                        style: mainText(),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        forCurrencyString(bills[index].billAmount),
                        style: mainText(),
                      ),
                      Text(
                        bills[index].billStatus,
                        style: labelPriColorText(),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Starting: ${myDateFormart(bills[index].startDate)}",
                        style: mainText(),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Ending: ${myDateFormart(bills[index].endDate)}",
                        style: mainText(),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${DateTime.parse(bills[index].endDate).difference(DateTime.now()).inDays} day(s) to the next bill",
                        style: labelPriColorText(),
                      ),
                    ],
                  ),
                  Text("Bill ID: $userGroupCode-${bills[index].billID}"),
                  const SizedBox(
                    height: 3,
                  ),
                  if (bills[index]
                          .billStatus
                          .toString()
                          .compareTo('Not Paid') ==
                      0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        actionButton("Mpesa Pay", Icons.money, () {
                          paymentPop(context, bills[index].billAmount,
                              bills[index].billID);
                        }),
                        // actionButton("Txn ID", Icons.edit, () {
                        //   mpesaPaymentCode(context, bills[index].billID);
                        // })
                      ],
                    )
                ],
              ),
            ),
            Column(
              children: [
                Icon(
                  Icons.arrow_right,
                  color: priColor,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    scaffoldMessenger = ScaffoldMessenger.of(context);
    con = context;
    return Scaffold(
      backgroundColor: priColorShade,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: priColor,
        title: Text(
          "Group Billing",
          style: appBarText(),
          textAlign: TextAlign.center,
        ),
        //centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              _populateTransactions();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              showExitPopup(context);
            },
          )
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 5, 24, 5),
            child: TextField(
                autofocus: false,
                controller: filterController,
                style: mainText(),
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: priColor,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: inactiveColor!),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15.0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: priColor),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15.0),
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(0),
                    hintText: 'Payment reference',
                    hintStyle: hiText()),
                onChanged: filterAction),
          ),
          Expanded(
            child: loadingBills
                ? Center(
                    child: CircularProgressIndicator(
                      //  color: priAccentColor,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(priColor),
                    ),
                  )
                : bills.isEmpty
                    ? emptyListView("No bills have been generated added yet..")
                    : ListView.builder(
                        itemCount: bills.length,
                        itemBuilder: _buildItemsForListView,
                      ),
          ),
        ],
      ),
    );
  }

  void filterAction(string) {
    setState(() {
      bills = allBills
          .where((u) => (u.payDate
                  .toString()
                  .toLowerCase()
                  .contains(string.toLowerCase()) ||
              u.paymentReference
                  .toString()
                  .toLowerCase()
                  .contains(string.toLowerCase())))
          .toList();
    });
    //});
  }

  void payMpesa(billAmount, String phone, billID) {
    var client = http.Client();

    client.post(Uri.parse("https://tinypesa.com/api/v1/express/initialize"),
        body: {
          "amount": billAmount,
          "msisdn": phone,
        },
        headers: {
          "Accept": "application/json",
          "Apikey": "Gxf2aSGgLoi"
        }).then((response) {
      //send the requestID to server
      //DialogBuilder(context).hideOpenDialog();
      //print(response.body);
      //print();

      var client = http.Client();
      client.post(Uri.parse("${urlRoot}updateTinyPesa.php"), body: {
        "tinypesaRequestID": json.decode(response.body)['request_id'],
        "billID": billID,
      }).then((response) {
        //DialogBuilder(context).hideOpenDialog();
      });

      client.close();
    });
  }

  Future<void> paymentPop(BuildContext context, billAmount, billID) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text(
                "Payment",
                style: mainAccentText(),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      "Enter the Phone Number where an MPESA promt will be send to complete the payment."),
                  buildTextField(Icons.comment, 'eg. 0720000000', false,
                      TextInputType.phone, phoneController, 1)
                ],
              ),
              actions: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      actionButton('Cancel', Icons.cancel, () {
                        Navigator.pop(context);
                      }),
                    ])
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> mpesaPaymentCode(BuildContext context, billID) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text(
                "MPESA CODE",
                style: mainAccentText(),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      "Enter the MPESA CODE that was received upon payment."),
                  buildCodeTextField(Icons.receipt_rounded, 'Transaction Code',
                      false, TextInputType.text, mpesacodeController, 1, true),
                ],
              ),
              actions: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      actionButton('Cancel', Icons.cancel, () {
                        Navigator.pop(context);
                      }),
                      actionButton('Submit', Icons.check_circle, () {
                        if (mpesacodeController.text.trim().length < 9) {
                          showSnackBar(
                              "Enter a valid MPESA code, 10 characters long");
                          return;
                        } else {
                          DialogBuilder(context).showLoadingIndicator(
                              "Submitting MPESA code...", "Payment..");
                          submitMPESACODE(
                              context, billID, mpesacodeController.text.trim());
                        }
                      })
                    ])
              ],
            ),
          );
        });
      },
    );
  }

  void submitMPESACODE(BuildContext context, billID, mpesacode) {
    var client = http.Client();
    client.post(Uri.parse("${urlRoot}submitMPESACODE.php"), body: {
      "billID": billID,
      "mpesacode": mpesacode,
    }).then((response) {
      DialogBuilder(context).hideOpenDialog();

      client.close();
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['code'] == 1 || jsonResponse['code'] == 0) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(
                        jsonResponse['code'] == 1
                            ? Icons.check_circle
                            : Icons.info,
                        color: priColor),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "MPESA Payment",
                      style: mainAccentText(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                content: Text(
                  jsonResponse['message'],
                  style: mainText(),
                  textAlign: TextAlign.center,
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      "Ok",
                      style: mainAccentText(),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    });
  }
}
