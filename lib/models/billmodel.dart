import 'dart:convert';

import '../util/configurations.dart';

class Bill {
  var billID;
  var billAmount;
  var groupCode;
  var billStatus;
  var createdDate;
  var startDate;
  var endDate;
  var paymentReference;
  var payDate;
  var billReason;
  static late List<Bill> _allBills;

  Bill({
    required this.billID,
    required this.billAmount,
    required this.groupCode,
    required this.billStatus,
    required this.createdDate,
    required this.startDate,
    required this.endDate,
    required this.paymentReference,
    required this.payDate,
    required this.billReason,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
        billID: json['billID'],
        billAmount: json['billAmount'],
        groupCode: json['groupCode'],
        billStatus: json['billStatus'],
        createdDate: json['createdDate'],
        startDate: json['startDate'],
        endDate: json['endDate'],
        paymentReference: json['paymentReference'],
        payDate: json['payDate'],
        billReason: json['billReason']);
  }

  static Resource<List<Bill>> all(url) {
    return Resource(
        url: "$urlRoot$url",
        parse: (response) {
          Iterable result = json.decode(response.body);
          _allBills = result.map((model) => Bill.fromJson(model)).toList();
          return _allBills;
        });
  }
}
