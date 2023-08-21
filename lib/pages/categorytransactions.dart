import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inuachama/models/transaction.dart';
import 'package:inuachama/util/configurations.dart';
import 'package:inuachama/util/templates.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

bool loadingTransactions = true;
late BuildContext con;
late String title;
late String scopeAccess;
late ScaffoldMessengerState scaffoldMessenger;
TextEditingController mpesacodeController = TextEditingController();

class SpecificTransactions extends StatefulWidget {
  const SpecificTransactions({Key? key}) : super(key: key);

  @override
  SpecificTransactionsState createState() => SpecificTransactionsState();
}

class SpecificTransactionsState extends State<SpecificTransactions> {
  List<Transaction> transactions = [];
  List<Transaction> allTransactions = [];
  String query = "";
  String? _sortValue;
  bool loadingTransactions = true;

  TextEditingController filterController = TextEditingController();

  SpecificTransactionsState();

  late String scope;

  @override
  void initState() {
    super.initState();
    _populateTransactions();
  }

  void _populateTransactions() {
    filterController.clear();
    transactions.clear();
    allTransactions.clear();
    _sortValue = null;
    Webservice().load(Transaction.all(Get.arguments['url'])).then((trans) => {
          setState(() => {
                allTransactions = trans,
                transactions = allTransactions,
                loadingTransactions = false
              })
        });
  }

  void _orderByTransactions(key) {
    setState(() {
      if (key.toString().compareTo("Amount") == 0) {
        transactions.sort((a, b) => a.amount.compareTo(b.amount));
      } else if (key.toString().compareTo("Amount Desc") == 0) {
        transactions.sort((b, a) => a.amount.compareTo(b.amount));
      } else if (key.toString().compareTo("Member Name") == 0) {
        transactions.sort((a, b) => a.name.compareTo(b.name));
      } else if (key.toString().compareTo("Member Name Desc") == 0) {
        transactions.sort((b, a) => a.name.compareTo(b.name));
      } else if (key.toString().compareTo("Date Created") == 0) {
        transactions.sort((a, b) => a.created_date.compareTo(b.created_date));
      } else if (key.toString().compareTo("Date Created Desc") == 0) {
        transactions.sort((b, a) => a.created_date.compareTo(b.created_date));
      } else if (key.toString().compareTo("Transaction Type") == 0) {
        transactions.sort((a, b) => a.t_type.compareTo(b.t_type));
      } else if (key.toString().compareTo("Transaction Type Desc") == 0) {
        transactions.sort((b, a) => a.t_type.compareTo(b.t_type));
      }
    });
  }

  Widget _buildItemsForListView(BuildContext context, int index) {
    return InkWell(
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        margin: const EdgeInsets.fromLTRB(8, 2, 8, 2),
        shadowColor: secbgColor,
        borderOnForeground: true,
        elevation: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Column(
                children: <Widget>[
                  GestureDetector(
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: transparentColor,
                        child: ClipOval(
                            child: CachedNetworkImage(
                                imageUrl: "${urlRoot}profilepics/" +
                                    transactions[index].image,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(
                                      color: adminColor,
                                      strokeWidth: 1,
                                    ),

                                // You can use LinearProgressIndicator or CircularProgressIndicator instead

                                errorWidget: (context, url, error) {
                                  return Image.asset("assets/images/blank.png");
                                })),

                        //backgroundColor: Colors.transparent,
                      ),
                      onTap: () {}),
                ],
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          transactions[index].name.toString().toUpperCase(),
                          style: labelBlackText().copyWith(color: adminColor),
                        ),
                        Text(
                          'TID: ' + transactions[index].t_id,
                          style: labelPriSmallColorText(),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 0,
                    ),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      color: transactions[index]
                                  .t_type
                                  .toString()
                                  .compareTo("Membership Fee") ==
                              0
                          ? priColorShade
                          : transactions[index]
                                      .t_type
                                      .toString()
                                      .compareTo("Interest Payment") ==
                                  0
                              ? greenColorShade
                              : transactions[index]
                                          .t_type
                                          .toString()
                                          .compareTo("Lateness Fine") ==
                                      0
                                  ? redColorShades
                                  : transactions[index]
                                              .t_type
                                              .toString()
                                              .compareTo("Loan Request") ==
                                          0
                                      ? goldColorShades
                                      : transactions[index]
                                                  .t_type
                                                  .toString()
                                                  .compareTo("Loan Payment") ==
                                              0
                                          ? blueColorShades
                                          : transactions[index]
                                                      .t_type
                                                      .toString()
                                                      .compareTo(
                                                          "Share Capital") ==
                                                  0
                                              ? pinkColorShades
                                              : transactions[index]
                                                          .t_type
                                                          .toString()
                                                          .compareTo(
                                                              "Group Income") ==
                                                      0
                                                  ? greenyColorShades
                                                  : adminColorShade,
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Text(
                          transactions[index].t_type,
                          style:
                              mainText().copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          forCurrency(transactions[index].amount),
                          style: MainAccentText(),
                        ),
                      ],
                    ),
                    if (transactions[index]
                                .t_type
                                .toString()
                                .compareTo("Contribution Payment") !=
                            0 &&
                        transactions[index]
                                .t_type
                                .toString()
                                .compareTo("Lateness Fine") !=
                            0 &&
                        transactions[index]
                                .t_type
                                .toString()
                                .compareTo("Group Expense") !=
                            0 &&
                        transactions[index]
                                .t_type
                                .toString()
                                .compareTo("Membership Fee") !=
                            0)
                      Text(
                        "Loan ID: ${transactions[index].loanID}",
                        style: mainText(),
                      ),
                    const SizedBox(
                      height: 5,
                    ),
                    //if (transactions[index].receipt.toString().isNotEmpty)

                    Text(
                      "Ref. Code: ${transactions[index].transactionCode}",
                      style: mainText(),
                    ),

                    Text(
                      DateFormatter().getVerboseDateTimeRepresentation(
                          myDateFormartted(transactions[index].created_date)),
                      style: mainText(),
                    ),

                    if (transactions[index].description.toString().length > 1)
                      Row(children: <Widget>[
                        const SizedBox(
                          height: 5,
                        ),
                        Icon(
                          Icons.chat,
                          color: priAccentColor,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Flexible(
                          child: Text(transactions[index].description,
                              style: verysmallText()),
                        ),
                      ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        if (transactions[index].isPaid.toString().compareTo('0') == 0 &&
            scopeAccess.compareTo('personal') == 0) {
          mpesaPaymentCode(context, transactions[index].t_id);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    scopeAccess = Get.arguments['scope'];
    scaffoldMessenger = ScaffoldMessenger.of(context);
    con = context;
    return Scaffold(
      backgroundColor: priColorShade,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: priColor,
        title: Text(
          "${Get.arguments['tTypes']} (${transactions.length})",
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
          sortOptions(),
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
                    hintText: 'Ref. code, TID, Name, or LoanID',
                    hintStyle: hiText()),
                onChanged: filterAction),
          ),
          Expanded(
            child: loadingTransactions
                ? Center(
                    child: CircularProgressIndicator(
                      //  color: priAccentColor,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(priColor),
                    ),
                  )
                : transactions.isEmpty
                    ? emptyListView("No transactions added yet..")
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: _buildItemsForListView,
                      ),
          ),
        ],
      ),
    );
  }

  void filterAction(string) {
    setState(() {
      transactions = allTransactions
          .where((u) => (u.name
                  .toString()
                  .toLowerCase()
                  .contains(string.toLowerCase()) ||
              u.amount
                  .toString()
                  .toLowerCase()
                  .contains(string.toLowerCase()) ||
              u.t_id.toString().toLowerCase().contains(string.toLowerCase()) ||
              u.transactionCode
                  .toString()
                  .toLowerCase()
                  .contains(string.toLowerCase()) ||
              u.loanID.toString().toLowerCase().contains(string.toLowerCase())))
          .toList();
    });
    //});
  }

  Widget sortOptions() {
    return DropdownButton<String>(
      focusColor: Colors.white,
      value: _sortValue,
      elevation: 1,
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.black,
      items: <String>[
        'Amount',
        'Amount Desc',
        'Member Name',
        'Member Name Desc',
        'Date Created',
        'Date Created Desc',
        'Transaction Type',
        'Transaction Type Desc'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: labelPriSmallColorText(),
          ),
        );
      }).toList(),
      hint: Text(
        "Specify Order Criteria",
        style: labelPriSmallColorText(),
      ),
      onChanged: (String? value) {
        setState(() {
          _sortValue = value;
          _orderByTransactions(_sortValue);
        });
      },
    );
  }

  Future<void> mpesaPaymentCode(BuildContext context, transactionID) async {
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
                "Submit MPESA",
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
                          submitMPESACODE(context, transactionID,
                              mpesacodeController.text.trim());
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

  void submitMPESACODE(BuildContext context, transactionID, mpesacode) {
    var client = http.Client();
    client.post(Uri.parse("${urlRoot}submitcodetransaction.php"), body: {
      "transactionID": transactionID,
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
                      _populateTransactions();
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
