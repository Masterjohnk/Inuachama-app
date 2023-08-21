import 'dart:convert';

import '../util/configurations.dart';

class Transaction {
  var t_id;
  var t_type;
  double amount;
  var loanID;
  var guarantor;
  var guaranteed_amount;
  var guarantor_approved;
  var description;
  var for_who;
  var approved_date;
  var created_date;
  var name;
  var status;
  var isPaid;
  String transactionCode;
  var image;
  static late List<Transaction> _allTransaction;

  Transaction(
      {required this.t_id,
      required this.t_type,
      required this.amount,
      required this.image,
      required this.name,
      required this.status,
      required this.description,
      required this.created_date,
      required this.transactionCode,
      required this.loanID,
      required this.isPaid});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
        t_type: json['t_type'] ?? '',
        image: json['image'] ?? '',
        t_id: json['t_id'] ?? '',
        description: json['description'] ?? '',
        created_date: json['created_date'] ?? '',
        loanID: json['loanID'] ?? '',
        isPaid: json['isPaid'] ?? '',
        status: json['status'] ?? '',
        transactionCode:
            json['receipt'] == null || json['receipt'].toString().isEmpty
                ? "-"
                : json['receipt'] ?? '',
        amount: double.parse(json['amount']),
        name: json['fname'] + " " + json['lname']);
  }

  static Resource<List<Transaction>> all(url) {
    return Resource(
        url: "$urlRoot$url",
        parse: (response) {
          //print(response.body);
          Iterable result = json.decode(response.body);
          _allTransaction =
              result.map((model) => Transaction.fromJson(model)).toList();
          return _allTransaction;
        });
  }

  static Resource<List<Transaction>> recent(groupCode) {
    String urlString = "recentTransactions.php?groupCode=$groupCode";
    return Resource(
        url: "$urlRoot$urlString",
        parse: (response) {
          Iterable result = json.decode(response.body);
          _allTransaction =
              result.map((model) => Transaction.fromJson(model)).toList();
          return _allTransaction;
        });
  }

  static Resource<List<Transaction>> pendingLoans(groupCode) {
    String urlString = "pendingLoans.php?groupCode=$groupCode";
    return Resource(
        url: "$urlRoot$urlString",
        parse: (response) {
          Iterable result = json.decode(response.body);
          _allTransaction =
              result.map((model) => Transaction.fromJson(model)).toList();
          return _allTransaction;
        });
  }
}
