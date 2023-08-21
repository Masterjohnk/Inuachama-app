import 'dart:convert';

import '../util/configurations.dart';

class DashBoardData {
  var total_contribution,
      membership_fee,
      total_fines,
      total_group_expenses,
      total_taken_loans,
      value_of_loans_waiting_approval,
      loans_waiting_approval,
      interest_this_month,
      interest_paid_so_far,
      current_month_average_contribution,
      current_month_highest_contribution,
      current_month_total_contribution,
      current_month_total_loan_taken,
      current_month_total_loan_paid,
      total_repayed_loans,
      contributors,
      totalUnPaidLoans,
      totalUnPaidInterest,
      totalUnPaidFines,
      total_share_capital,
      total_other_incomes;
  static late List<DashBoardData> _allDashBoardData;

  DashBoardData({
    required this.total_contribution,
    required this.membership_fee,
    required this.total_fines,
    required this.total_group_expenses,
    required this.total_taken_loans,
    required this.value_of_loans_waiting_approval,
    required this.loans_waiting_approval,
    required this.interest_this_month,
    required this.interest_paid_so_far,
    required this.contributors,
    required this.current_month_average_contribution,
    required this.current_month_highest_contribution,
    required this.current_month_total_contribution,
    required this.current_month_total_loan_taken,
    required this.current_month_total_loan_paid,
    required this.total_repayed_loans,
    required this.totalUnPaidFines,
    required this.totalUnPaidInterest,
    required this.totalUnPaidLoans,
    required this.total_share_capital,
    required this.total_other_incomes,
  });

  factory DashBoardData.fromJson(Map<String, dynamic> json) {
    //DateFormat.yMd('en_US').parse(json['created_date']),
    return DashBoardData(
        total_contribution: json['total_contribution'] ?? "0.0",
        membership_fee: json['membership_fee'] ?? "0.0",
        total_fines: json['total_fines'] ?? "0.0",
        total_group_expenses: json['total_group_expenses'] ?? "0.0",
        total_taken_loans: json['total_taken_loans'] ?? "0.0",
        value_of_loans_waiting_approval:
            json['value_of_loans_waiting_approval'] ?? "0.0",
        loans_waiting_approval: json['loans_waiting_approval'] ?? "0.0",
        contributors: json['contributors'] ?? "0.0",
        current_month_total_contribution:
            json['current_month_total_contribution'] ?? "0.0",
        current_month_total_loan_paid:
            json['current_month_total_loan_paid'] ?? "0.0",
        current_month_highest_contribution:
            json['current_month_highest_contribution'] ?? "0.0",
        interest_this_month: json['interest_this_month'] ?? "0.0",
        total_repayed_loans: json['total_repayed_loans'] ?? "0.0",
        interest_paid_so_far: json['interest_paid_so_far'] ?? "0.0",
        current_month_total_loan_taken:
            json['current_month_total_loan_taken'] ?? "0.0",
        current_month_average_contribution:
            json['current_month_average_contribution'] ?? "0.0",
        totalUnPaidFines: json['totalUnPaidFines'] ?? "0.0",
        totalUnPaidInterest: json['totalUnPaidInterests'] ?? "0.0",
        totalUnPaidLoans: json['totalUnPaidLoans'] ?? "0.0",
        total_share_capital: json['total_share_capital'] ?? "0.0",
        total_other_incomes: json['total_other_incomes'] ?? "0.0");
  }

  static Resource<List<DashBoardData>> all(groupCode) {
    return Resource(
        url: "${urlRoot}dashboard.php?groupCode=$groupCode",
        parse: (response) {
          Iterable result = json.decode(response.body);
          _allDashBoardData =
              result.map((model) => DashBoardData.fromJson(model)).toList();
          return _allDashBoardData;
        });
  }
}
