import 'dart:convert';

import '../util/configurations.dart';

class ProfileData {
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
      deviceID;
  static late List<ProfileData> _profileData;

  ProfileData({
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
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
        fname: json['fname'],
        lname: json['lname'],
        email: json['email'],
        title: json['title'],
        tac: json['tac'],
        role: json['role'],
        image: json['image'],
        joinDate: json['join_date'],
        active: json['active'],
        deviceID: json['deviceid'],
        phone: json['phone']);
  }

  static Resource<List<ProfileData>> getProfile(String phone) {
    return Resource(
        url: "${urlRoot}getprofile.php?phone=$phone",
        parse: (response) {
          Iterable result = json.decode(response.body);
          _profileData =
              result.map((model) => ProfileData.fromJson(model)).toList();
          return _profileData;
        });
  }
}
