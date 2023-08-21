import 'dart:convert';

import '../util/configurations.dart';

class Member {
  var fname,
      lname,
      phone,
      email,
      role,
      title,
      image,
      joinDate,
      tac,
      active,
      deviceID,
      memberID;
  static late List<Member> _allMembers;

  Member({
    required this.fname,
    required this.lname,
    required this.email,
    required this.role,
    required this.title,
    required this.image,
    required this.joinDate,
    required this.tac,
    required this.active,
    required this.phone,
    required this.deviceID,
    required this.memberID,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      fname: json['fname'],
      lname: json['lname'],
      email: json['email'],
      title: json['title'],
      tac: json['tac'],
      role: json['userRole'],
      image: json['image'],
      joinDate: json['join_date'],
      active: json['userActive'],
      deviceID: json['deviceid'],
      phone: json['phone'],
      memberID: json['memberID'] ?? "",
    );
  }

  static Resource<List<Member>> getAllMembers(groupCode) {
    return Resource(
        url: "${urlRoot}getmembers.php?groupCode=$groupCode",
        parse: (response) {
          print(response.body);
          Iterable result = json.decode(response.body);
          _allMembers = result.map((model) => Member.fromJson(model)).toList();
          return _allMembers;
        });
  }
}
