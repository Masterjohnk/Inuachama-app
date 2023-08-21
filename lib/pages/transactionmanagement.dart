import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inuachama/models/transaction.dart';
import 'package:inuachama/util/configurations.dart';
import 'package:http/http.dart' as http;

TextEditingController amountController = TextEditingController();
TextEditingController codeController = TextEditingController();
TextEditingController commentController = TextEditingController();
bool loadingTransactions = true;
late BuildContext con;
late String title;
String userPhone = "";
List<String> items = [];
List<String> transactionTypes = [];
String dropDownValue = '';
late String transactionStatus;
late String userGroupCode;

class ManageTransactions extends StatefulWidget {
  const ManageTransactions({Key? key}) : super(key: key);

  @override
  ManageTransactionsState createState() => ManageTransactionsState();
}

class ManageTransactionsState extends State<ManageTransactions> {
  List<Transaction> transactions = [];
  List<Transaction> allTransactions = [];

  String query = "";
  String? _sortValue;
  bool loadingTransactions = true;

  TextEditingController filterController = TextEditingController();

  ManageTransactionsState();

  final Prefs _prefs = Prefs();

  @override
  void initState() {
    super.initState();
    getLoggedUser();
  }

  void getGroupCode() {
    _prefs.getStringValuesSF('groupCode').then((groupCode) => {
          setState(() => {userGroupCode = groupCode!, _populateTransactions()})
        });
  }

  void getLoggedUser() {
    _prefs.getLoggedUSer().then((user) => {
          setState(() => {
                userPhone = user.phone,
                getGroupCode(),
              })
        });
  }

  void _populateTransactions() {
    filterController.clear();
    transactions.clear();
    allTransactions.clear();
    _sortValue = null;
    Webservice()
        .load(Transaction.all(
            "alltransactions.php?groupCode=$userGroupCode&scope=group&phone=$userPhone"))
        .then((trans) => {
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
      } else if (key.toString().compareTo("Approved First") == 0) {
        transactions.sort((a, b) => a.status.compareTo(b.status));
      } else if (key.toString().compareTo("Waiting First") == 0) {
        transactions.sort((b, a) => a.status.compareTo(b.status));
      }
    });
  }

  Widget _buildItemsForListView(BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      shadowColor: priColor,
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
                      backgroundColor: priAccentColor,
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
                            }),
                      ),

                      //backgroundColor: Colors.transparent,
                    ),
                    onTap: () {}),
              ],
            ),
            const SizedBox(
              width: 10,
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
                        style: labelPriSmallColorText(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    transactions[index].t_type,
                    style: mainText(),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    forCurrency(transactions[index].amount),
                    style: MainAccentText(),
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
                  Text(
                    'TID: ' + transactions[index].t_id,
                    style: labelPriSmallColorText(),
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
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                actionButton(
                    transactions[index]
                                .status
                                .toString()
                                .compareTo('Approved') ==
                            0
                        ? 'Waiting'
                        : 'Approve',
                    transactions[index]
                                .status
                                .toString()
                                .compareTo('Approved') ==
                            0
                        ? Icons.timer
                        : Icons.done, () {
                  setState(() {
                    if (transactions[index]
                            .status
                            .toString()
                            .compareTo('Approved') ==
                        0) {
                      transactionStatus = "Waiting";
                    } else {
                      transactionStatus = "Approved";
                    }
                  });
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Row(children: [
                            Icon(
                                transactionStatus
                                            .toString()
                                            .compareTo('Approved') ==
                                        0
                                    ? Icons.done
                                    : Icons.timer,
                                color: priColor),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Set To $transactionStatus",
                              style: mainAccentText(),
                              textAlign: TextAlign.center,
                            ),
                          ]),
                          content: Text(
                            'Are you sure you want to set the transaction to $transactionStatus ?',
                            style: mainText(),
                            textAlign: TextAlign.center,
                          ),
                          actions: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  child: Text(
                                    "Cancel",
                                    style: mainAccentText(),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    'Set to $transactionStatus',
                                    style: mainAccentText(),
                                  ),
                                  onPressed: () {
                                    DialogBuilder(context).showLoadingIndicator(
                                        "Please wait as we $transactionStatus the transaction..",
                                        "$transactionStatus Transaction");
                                    approveorWaitTransaction(
                                        transactions[index].t_id);
                                  },
                                )
                              ],
                            )
                          ],
                        );
                      });
                }),
                const SizedBox(
                  height: 15,
                ),
                actionButton('Edit', Icons.edit, () {
                  edittransactionPopUP(context, index);
                  getTransactionTypes(index.toString());
                }),
                const SizedBox(
                  height: 15,
                ),
                actionButton('Delete', Icons.delete_forever, () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Row(children: [
                            Icon(Icons.delete, color: priColor),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Delete Transaction",
                              style: mainAccentText(),
                              textAlign: TextAlign.center,
                            ),
                          ]),
                          content: Text(
                            'Are you sure you want to delete the transaction?',
                            style: mainText(),
                            textAlign: TextAlign.center,
                          ),
                          actions: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  child: Text(
                                    "Cancel",
                                    style: mainAccentText(),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    "Delete",
                                    style: mainAccentText(),
                                  ),
                                  onPressed: () {
                                    DialogBuilder(context).showLoadingIndicator(
                                        "Please wait as we delete the transaction..",
                                        "Delete Transaction");
                                    deleteTransaction(transactions[index].t_id);
                                  },
                                )
                              ],
                            )
                          ],
                        );
                      });
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    con = context;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: priColor,
        title: Text(
          "Transaction Management (${transactions.length})",
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
              //_populateTransactions();
            },
          )
        ],
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
                    hintText: 'Ref. code, TID, Name or LoanID',
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
                    ? emptyListView("No transactions added..")
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
        'Approved First',
        'Waiting First',
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

  void deleteTransaction(String transactionID) {
    var client = http.Client();
    client.post(Uri.parse("${urlRoot}deltransaction.php"), body: {
      "tid": transactionID,
    }).then((response) {
      //setState(() {
      DialogBuilder(context).hideOpenDialog();
      //});
      client.close();
      if (mounted && response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['code'] == 1 || jsonResponse['code'] == 0) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Row(children: [
                  Icon(
                      jsonResponse['code'] == 1
                          ? Icons.check_circle
                          : Icons.error,
                      color: priColor),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Transaction",
                    style: mainAccentText(),
                    textAlign: TextAlign.center,
                  ),
                ]),
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

  void approveorWaitTransaction(String transactionID) {
    var client = http.Client();
    client.post(Uri.parse("${urlRoot}approveordissapprove.php"), body: {
      "tid": transactionID,
      "status": transactionStatus,
      "approver": userPhone,
    }).then((response) {
      //setState(() {
      DialogBuilder(context).hideOpenDialog();
      //});
      client.close();
      if (mounted && response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['code'] == 1 || jsonResponse['code'] == 0) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Row(children: [
                  Icon(
                      jsonResponse['code'] == 1
                          ? Icons.check_circle
                          : Icons.error,
                      color: priColor),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Transaction",
                    style: mainAccentText(),
                    textAlign: TextAlign.center,
                  ),
                ]),
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

  Future<void> edittransactionPopUP(BuildContext context, int index) async {
    setState(() {
      amountController.text = transactions[index].amount.toString();
      codeController.text = transactions[index].transactionCode.toString();
      commentController.text = transactions[index].description.toString();
    });
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
                "Edit Transactions",
                style: mainAccentText(),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton(
                    value: dropDownValue,
                    hint: Text(
                      "Select Transaction Type",
                      style: mainText(),
                      textAlign: TextAlign.center,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: items.map((String items) {
                      return DropdownMenuItem(
                          value: items,
                          child: Text(
                            items,
                            style: mainText(),
                          ));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropDownValue = newValue!;
                      });
                    },
                  ),
                  buildTextField(
                      Icons.money,
                      'Amount',
                      false,
                      const TextInputType.numberWithOptions(
                          signed: false, decimal: true),
                      amountController),
                  buildCodeTextField(Icons.receipt_rounded, 'Transaction Code',
                      false, TextInputType.text, codeController, 1, true),
                  buildTextField(Icons.comment, 'Comments', false,
                      TextInputType.text, commentController, 5)
                ],
              ),
              actions: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      actionButton('Cancel', Icons.cancel, () {
                        Navigator.pop(context);
                      }),
                      actionButton('Update', Icons.done, () {
                        DialogBuilder(context).showLoadingIndicator(
                            "Please wait as we update the transaction..",
                            "Transaction");
                        updateTransaction(index);
                      })
                    ])
              ],
            ),
          );
        });
      },
    );
  }

  void getTransactionTypes(String option) {
    var client = http.Client();
    client.post(Uri.parse('${urlRoot}gettransactioncats.php'), body: {}).then(
        (response) {
      client.close();
      if (mounted && response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        items.clear();
        transactionTypes.clear();
        jsonResponse.forEach((s) => transactionTypes.add(s['type_name']));
        setState(() {
          items = transactionTypes;
          dropDownValue = transactions[int.parse(option)].t_type;
          //print("Method " + transactions[int.parse(option)].t_type);
        });
      }
    });
  }

  void updateTransaction(int index) {
    var client = http.Client();
    client.post(Uri.parse("${urlRoot}updatetransaction.php"), body: {
      "amount": amountController.text.trim(),
      "type": dropDownValue,
      "description": commentController.text.trim(),
      "code": codeController.text.trim(),
      "tid": transactions[index].t_id,
    }).then((response) {
      //setState(() {
      DialogBuilder(context).hideOpenDialog();
      //});
      client.close();
      if (mounted && response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['code'] == 1 || jsonResponse['code'] == 0) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Row(children: [
                  Icon(
                      jsonResponse['code'] == 1
                          ? Icons.check_circle
                          : Icons.error,
                      color: priColor),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Update Transaction",
                    style: mainAccentText(),
                    textAlign: TextAlign.center,
                  ),
                ]),
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
