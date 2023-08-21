import 'dart:convert';

import '../util/configurations.dart';

class PersonalDashBoardData {
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
      total_members,
      contributors,
      yourTotalUnpaidLoans,
      yourTotalUnpaidInterests,
      yourTotalUnpaidFines;

  static late List<PersonalDashBoardData> _allDashBoardData;

  PersonalDashBoardData({
    required this.total_contribution,
    required this.yourTotalUnpaidFines,
    required this.total_fines,
    required this.yourTotalUnpaidInterests,
    required this.total_taken_loans,
    required this.value_of_loans_waiting_approval,
    required this.loans_waiting_approval,
    required this.yourTotalUnpaidLoans,
    required this.interest_this_month,
    required this.interest_paid_so_far,
    required this.contributors,
    // required this.current_month_average_contribution,
    // required this.current_month_highest_contribution,
    // required this.current_month_total_contribution,
    // required this.current_month_total_loan_taken,
    // required this.current_month_total_loan_paid,
    required this.total_repayed_loans,
  });

  factory PersonalDashBoardData.fromJson(Map<String, dynamic> json) {
    return PersonalDashBoardData(
      total_contribution: json['total_contribution'] ?? "0.0",
      // membership_fee: json['membership_fee'] ?? "0.0",
      total_fines: json['total_fines'] ?? "0.0",
      // total_group_expenses: json['total_group_expenses'] ?? "0.0",
      total_taken_loans: json['total_taken_loans'] ?? "0.0",
      value_of_loans_waiting_approval:
          json['value_of_loans_waiting_approval'] ?? "0.0",
      loans_waiting_approval: json['loans_waiting_approval'] ?? "0.0",
      contributors: json['contributors'] ?? "0.0",
      // current_month_total_contribution:
      //     json['current_month_total_contribution'] ?? "0.0",
      // current_month_total_loan_paid:
      //     json['current_month_total_loan_paid'] ?? "0.0",
      // current_month_highest_contribution:
      //     json['current_month_highest_contribution'] ?? "0.0",
      interest_this_month: json['interest_this_month'] ?? "0.0",
      total_repayed_loans: json['total_paid_loans'] ?? "0.0",
      interest_paid_so_far: json['interest_paid_so_far'] ?? "0.0",
      yourTotalUnpaidInterests: json['yourTotalUnPaidInterests'] ?? "0.0",
      yourTotalUnpaidLoans: json['yourTotalUnPaidLoans'] ?? "0.0",
      yourTotalUnpaidFines: json['yourTotalUnPaidFines'] ?? "0.0",
    );
  }

  static Resource<List<PersonalDashBoardData>> all(
      String phone, String userGroupCode) {
    return Resource(
        url:
            "${urlRoot}personal_dashboard.php?phone=$phone&groupCode=$userGroupCode",
        parse: (response) {
          Iterable result = json.decode(response.body);
          _allDashBoardData = result
              .map((model) => PersonalDashBoardData.fromJson(model))
              .toList();
          return _allDashBoardData;
        });
  }
}
