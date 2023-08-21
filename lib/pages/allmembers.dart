import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inuachama/models/members.dart';
import 'package:inuachama/util/configurations.dart';

bool loadingMembers = true;
late BuildContext con;

class AllMembers extends StatefulWidget {
  const AllMembers() : super();

  @override
  createState() => AllMembersState();
}

class AllMembersState extends State<AllMembers> {
  List<Member> members = [];
  List<Member> allMembers = [];
  String query = "";
  String? _sortValue;
  final Prefs _prefs = Prefs();
  bool loadingMembers = true;
  var userGroupCode = "";
  TextEditingController filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getGroupCode();
  }

  void getGroupCode() {
    _prefs.getStringValuesSF('groupCode').then((groupCode) => {
          setState(() => {
                userGroupCode = groupCode!,
                _populateTransactions(),
              })
        });
  }

  void _populateTransactions() {
    filterController.clear();
    members.clear();
    allMembers.clear();
    _sortValue = null;
    Webservice().load(Member.getAllMembers(userGroupCode)).then((mems) => {
          setState(() =>
              {allMembers = mems, members = allMembers, loadingMembers = false})
        });
  }

  void _orderByMembers(key) {
    setState(() {
      if (key.toString().compareTo("Member ID") == 0) {
        members.sort((a, b) => a.memberID.compareTo(b.memberID));
      } else if (key.toString().compareTo("Member ID Desc") == 0) {
        members.sort((b, a) => a.memberID.compareTo(b.memberID));
      } else if (key.toString().compareTo("First Name") == 0) {
        members.sort((a, b) => a.fname.compareTo(b.fname));
      } else if (key.toString().compareTo("First Name Desc") == 0) {
        members.sort((b, a) => a.fname.compareTo(b.fname));
      } else if (key.toString().compareTo("Date Created") == 0) {
        members.sort((a, b) => a.joinDate.compareTo(b.joinDate));
      } else if (key.toString().compareTo("Date Created Desc") == 0) {
        members.sort((b, a) => a.joinDate.compareTo(b.joinDate));
      } else if (key.toString().compareTo("Email") == 0) {
        members.sort((a, b) => a.email.compareTo(b.email));
      } else if (key.toString().compareTo("Email Desc") == 0) {
        members.sort((b, a) => a.email.compareTo(b.email));
      }
    });
  }

  Widget _buildItemsForListView2(BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      shadowColor: priColor,
      borderOnForeground: true,
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Column(
              children: <Widget>[
                GestureDetector(
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: priAccentColor,
                      child: ClipOval(
                          child: CachedNetworkImage(
                              imageUrl: "${urlRoot}profilepics/" +
                                  members[index].image,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text.rich(
                  TextSpan(
                    style: mainText(),
                    children: [
                      WidgetSpan(
                        child: Icon(
                          Icons.account_circle_outlined,
                          color: priColor,
                          size: 20,
                        ),
                      ),
                      TextSpan(
                        text: "${" " + members[index].fname} " +
                            members[index].lname,
                        style: labelPriSmallColorText(),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                if (members[index].memberID.toString().isNotEmpty &&
                    members[index].memberID.toString().length != 0)
                  Text.rich(
                    TextSpan(
                      style: mainText(),
                      children: [
                        WidgetSpan(
                          child: Icon(
                            Icons.vpn_key,
                            color: priColor,
                            size: 20,
                          ),
                        ),
                        TextSpan(
                          text: " " + members[index].memberID,
                          style: mainText(),
                        )
                      ],
                    ),
                  ),
                Text.rich(
                  TextSpan(
                    style: mainText(),
                    children: [
                      WidgetSpan(
                        child: Icon(
                          Icons.card_membership_sharp,
                          color: priColor,
                          size: 20,
                        ),
                      ),
                      TextSpan(
                        text: " " + members[index].title,
                        style: mainText(),
                      )
                    ],
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),
                Text.rich(
                  TextSpan(
                    style: mainText(),
                    children: [
                      WidgetSpan(
                        child: Icon(
                          Icons.phone_android,
                          color: priColor,
                          size: 20,
                        ),
                      ),
                      TextSpan(
                        text: " " + members[index].phone,
                        style: mainText(),
                      )
                    ],
                  ),
                ),

                Text.rich(
                  TextSpan(
                    style: mainText(),
                    children: [
                      WidgetSpan(
                        child: Icon(
                          Icons.alternate_email,
                          color: priColor,
                          size: 20,
                        ),
                      ),
                      TextSpan(
                        text: " " + members[index].email,
                        style: MainAccentText(),
                      )
                    ],
                  ),
                ),
                //

                const SizedBox(
                  height: 5,
                ),

                Text.rich(
                  TextSpan(
                    style: mainText(),
                    children: [
                      WidgetSpan(
                        child: Icon(
                          Icons.calendar_today,
                          color: priColor,
                          size: 20,
                        ),
                      ),
                      TextSpan(
                        text:
                            " Since: ${DateFormatter().getVerboseDateTimeRepresentation(myDateFormartted(members[index].joinDate))}",
                        style: mainText(),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsForListView(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 3, bottom: 3),
      child: Container(
        height: 350,
        //width: double.infinity,
        //color: greyColor,
        decoration: BoxDecoration(
          //borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: CachedNetworkImageProvider(
              "${urlRoot}profilepics/" + members[index].image,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomLeft, colors: [
            Colors.black.withOpacity(.9),
            Colors.black.withOpacity(.4),
            Colors.black.withOpacity(.2),
          ])),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${" " + members[index].fname} " + members[index].lname,
                  style: myTextStyle(bgColor, 20, FontWeight.w900),
                ),

                const SizedBox(
                  height: 5,
                ),
                if (members[index].memberID.toString().isNotEmpty &&
                    members[index].memberID.toString().length != 0)
                  Text(" " + members[index].memberID,
                      style: myTextStyle(bgColor, 20, FontWeight.normal)),
                const SizedBox(
                  height: 5,
                ),

                Text(
                  " " + members[index].title,
                  style: myTextStyle(bgColor, 20, FontWeight.normal),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(" " + members[index].phone,
                    style: myTextStyle(bgColor, 14, FontWeight.normal)),

                Text(" " + members[index].email,
                    style: myTextStyle(bgColor, 14, FontWeight.normal)),

                //

                const SizedBox(
                  height: 5,
                ),

                Text(
                    " Since: ${DateFormatter().getVerboseDateTimeRepresentation(myDateFormartted(members[index].joinDate))}",
                    style: myTextStyle(bgColor, 14, FontWeight.normal)),
                // GestureDetector(
                //   child: Icon(
                //     Icons.chat,
                //     color: Colors.green,
                //   ),
                //   onTap: () {
                //     var whatsappUrl =
                //         "whatsapp://send?phone=254${members[index].phone.toString().substring(1)}&text=${Uri.parse("hi")}";
                //     try {
                //       canLaunchUrl(Uri.parse(whatsappUrl));
                //     } catch (e) {
                //       //To handle error and display error message
                //
                //     }
                //   },
                // )
              ],
            ),
          ),
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
          "All Members (${members.length})",
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
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            sortOptions(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 5, 24, 5),
              child: TextField(
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
                      hintText: 'Filter by Name, Member ID or Phone',
                      hintStyle: hiText()),
                  onChanged: filterAction),
            ),
            loadingMembers
                ? Center(
                    child: CircularProgressIndicator(
                      //  color: priAccentColor,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(priColor),
                    ),
                  )
                : members.isEmpty
                    ? emptyListView("No members added yet..")
                    : Expanded(
                        child: ListView.builder(
                          //scrollDirection: Axis.horizontal,
                          itemCount: members.length,
                          itemBuilder: _buildItemsForListView,
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  void filterAction(string) {
    // Debouncer(milliseconds: 500).run(() {
    setState(() {
      members = allMembers
          .where((u) => (u.fname
                  .toString()
                  .toLowerCase()
                  .contains(string.toLowerCase()) ||
              u.lname.toString().toLowerCase().contains(string.toLowerCase()) ||
              u.memberID
                  .toString()
                  .toLowerCase()
                  .contains(string.toLowerCase()) ||
              u.phone.toString().toLowerCase().contains(string.toLowerCase()) ||
              u.email.toString().toLowerCase().contains(string.toLowerCase())))
          .toList();
    });
    //});
  }

  Widget sortOptions() {
    return DropdownButton<String>(
      focusColor: Colors.white,
      value: _sortValue,
      elevation: 5,
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.black,
      items: <String>[
        'Member ID',
        'Member ID Desc',
        'First Name',
        'First Name Desc',
        'Email',
        'Email Desc',
        'Date Joined',
        'Date Joined Desc',
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
          _orderByMembers(_sortValue);
        });
      },
    );
  }
}
