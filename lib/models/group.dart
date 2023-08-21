import 'dart:convert';

import '../util/configurations.dart';

class Group {
  var groupID;
  var groupCode;
  var groupName;
  var groupImage;
  var groupCreateDate;
  var groupStatus;
  var groupStatusReason;
  var groupMembers;
  var userRole;
  var userActive;
  var groupSize;
  var groupInterestRate;
  var loansModule;
  var membershipFeeModule;
  var expensesModule;
  var finesModule;
  var alertsToAll;
  var contributionReminder;
  var downloadReport;
  var accessReport;
  var adminRecords;
  var interestRateType;
  var interestRateFrequency;
  var contributionReminderDate;
  var contributionEvents;
  var adminSelfApprove;
  var shareCapital;
  var incomeModule;

  static late List<Group> _allGroups;

  Group({
    required this.groupID,
    required this.groupCode,
    required this.groupCreateDate,
    required this.groupName,
    required this.groupImage,
    required this.groupStatus,
    required this.groupStatusReason,
    required this.groupMembers,
    required this.userActive,
    required this.userRole,
    required this.groupSize,
    required this.groupInterestRate,
    required this.alertsToAll,
    required this.expensesModule,
    required this.finesModule,
    required this.loansModule,
    required this.membershipFeeModule,
    required this.contributionReminder,
    required this.downloadReport,
    required this.accessReport,
    required this.adminRecords,
    required this.interestRateType,
    required this.interestRateFrequency,
    required this.contributionReminderDate,
    required this.contributionEvents,
    required this.adminSelfApprove,
    required this.shareCapital,
    required this.incomeModule,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupID: json['groupID'] ?? '',
      groupInterestRate: json['groupInterestRate'],
      groupCode: json['groupCode'] ?? '',
      groupCreateDate: json['groupCreateDate'] ?? '',
      groupName: json['groupName'] ?? '',
      groupStatus: json['groupStatus'] ?? '',
      groupStatusReason: json['groupStatusReason'] ?? '',
      groupMembers: json['groupMembers'] ?? '',
      groupImage: json['groupImage'] ?? '',
      userRole: json['userRole'] ?? '',
      userActive: json['userActive'] ?? '',
      groupSize: json['groupSize'] ?? '',
      loansModule: json['loansModule'] ?? '',
      expensesModule: json['groupExpenses'] ?? '',
      alertsToAll: json['alertToAll'] ?? '',
      finesModule: json['groupFines'] ?? '',
      membershipFeeModule: json['membeshipFee'] ?? '',
      contributionReminder: json['contributionReminders'] ?? '',
      downloadReport: json['downloadReport'] ?? '',
      accessReport: json['accessAllReports'] ?? '',
      adminRecords: json['adminRecords'] ?? '',
      interestRateType: json['InterestRateType'] ?? '',
      interestRateFrequency: json['InterestRateFrequency'] ?? '',
      contributionReminderDate: json['contributionReminderDate'] ?? '',
      contributionEvents: json['contributionEvents'] ?? '',
      adminSelfApprove: json['adminSelfApprove'],
      shareCapital: json['shareCapital'],
      incomeModule: json['incomeModule'],
    );
  }

  static Resource<List<Group>> all(url) {
    return Resource(
        url: "$urlRoot$url",
        parse: (response) {
          Iterable result = json.decode(response.body);
          _allGroups = result.map((model) => Group.fromJson(model)).toList();
          return _allGroups;
        });
  }
}
