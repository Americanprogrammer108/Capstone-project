import 'dart:typed_data';
import 'dart:async';
import 'package:capstone_project/group_chats/create_group/create_group.dart';
import 'package:capstone_project/services/notifications/local_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:capstone_project/services/auth/auth_service.dart';
import 'package:capstone_project/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../group_chats/create_group/add_members.dart';
import '../group_chats/group_chat_room.dart';
import '../group_chats/group_chat_screen.dart';
import 'Status.dart';
import 'add_user.dart';
import 'chat_page.dart';
import 'chat_user.dart';
import 'edit.dart';
import 'login_page.dart';


class HomePage extends StatefulWidget
{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  bool light1 = true;
  int currentPageIndex = 2;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Uint8List? _image;
  List myUsers = [];
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  //map variables
  Completer<GoogleMapController> _googleMapController = Completer();
  CameraPosition? _cameraPosition;
  Location? _location;
  LocationData? _currentLocation;

  //end of map variables
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  String myID = Uuid().v1();
  //group message variables
  // final String groupChatId, groupName;

  List membersList = [];
  bool isLoading = true;

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //end

  List groupList = [];

  List<ChatUser> _list = [];


  // for storing searched items
  // final List<ChatUser> _searchList = [];
  // // for storing search status
  // bool _isSearching = false;
  //

  var searchEmail = '';

  final TextEditingController _search = TextEditingController();
  List<Map<String, dynamic>> myUsersList = [];
  Map<String, dynamic>? userMap;

  void onSearch() async {
    print("You searched " + _search.text);
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  void onResultTap() async {
    bool isAlreadyExist = false;

    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      // await _firestore
      //     .collection('users')
      //     .doc(_auth.currentUser!.uid)
      //     .collection('myUsers')
      //     .doc(myID)
      //     .set({
      //   "name": map['Fullname'],
      //   "id": map['uid'],
      // });
    }
    _search.text = "";
    print("");
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), "images/WorldText.png")
        .then(
          (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  //map functions
  List<Marker> _marker = [];
  List<Marker> _usersLocations = [
    //my current location
    // Marker(
    //     markerId: MarkerId('1'),
    //     position: LatLng(_cameraPosition!.target.latitude, _cameraPosition!.target.longitude),
    //     infoWindow: InfoWindow(
    //         title: "My current location 1"
    //     ),
    //   ),
    // ),

  ];

  List<Marker> allmyuserslocations = [];

  @override
  void initState() {
    _init();
    super.initState();
    addCustomIcon();
    print(_marker);
    getAvailableGroups();
  }

  _init() async
  {
    _location = Location();
    _cameraPosition = CameraPosition(
        target: LatLng(0, 0),
        zoom: 15
    );
    LocationData? currentLocation = await _getCurrentLocation();
    _cameraPosition = CameraPosition(
        target: LatLng(
            currentLocation?.latitude ?? 0, currentLocation?.longitude ?? 0),
        zoom: 15
    );
    _usersLocations.add(Marker(
      markerId: MarkerId('1'),
      position: LatLng(_cameraPosition!.target.latitude, _cameraPosition!.target.longitude),
      infoWindow: InfoWindow(
          title: "You are here"
      ),
      // icon: markerIcon,
    ),
    );
    users.doc(user.uid).update({"latitude": _cameraPosition!.target.latitude})
        .then((value) => print("Latitude: " + _cameraPosition!.target.latitude.toString() ))
        .catchError((onError) => print("Update failed..."));
    users.doc(user.uid).update({"longitude": _cameraPosition!.target.longitude})
        .then((value) => print("Longitude: " + _cameraPosition!.target.longitude.toString() ))
        .catchError((onError) => print("Update failed..."));
    // print("Latitude: " + currentLocation!.latitude.toString() + " Longitude: " + currentLocation!.longitude.toString());
    _marker.add(Marker(
      markerId: MarkerId('Current location'),
      position: LatLng(_cameraPosition!.target.latitude, _cameraPosition!.target.longitude),
      infoWindow: InfoWindow(
          title: "You are here"
      ),
    ));
    moveToCurrentLocation();
    getAvailableLocations();
    //pick up at 16:57
  }

  Future <void> handleBackgroundMessage() async
  {
    print("Title " + "324");
    print("Body " + "324");
    print("OPayload " + "324");
  }

  Future<void> initNotifications() async
  {
    final _firebaseMessaging = FirebaseMessaging.instance;
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print("Token:" + fCMToken.toString());
    // _firebaseMessaging.instance.getInitialMessage().then(handleBackgroundMessage);
  }

  void getAvailableLocations() async {
    _usersLocations.clear();
    _marker.clear();

    String uid = _auth.currentUser!.uid;
    print(_usersLocations.length);
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('My Users')
        .get()
        .then((value) {
      setState(() {
        print(value.docs.length);
        for(int i = 0; i < value.docs.length; i++)
        {
          userMap = value.docs[i].data();
          print(userMap);
          _usersLocations.add(Marker(
            markerId: MarkerId('Current location'),
            position: LatLng(userMap!['latitude'], userMap!['latitude']),
            infoWindow: InfoWindow(
                title: "You are here"
            ),
          ));
        }
        print(_usersLocations.length);
        _marker.addAll(_usersLocations);
        final List<Marker> allUserLocations = _marker;
      });
    });
  }

  Future<List<Marker>> getLocations() async
  {
    _usersLocations.clear();
    _marker.clear();

    String uid = _auth.currentUser!.uid;
    print(_usersLocations.length);
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('My Users')
        .get()
        .then((value) {
      setState(() {
        print(value.docs.length);
        for(int i = 0; i < value.docs.length; i++)
        {
          userMap = value.docs[i].data();
          print(userMap);
          _usersLocations.add(Marker(
            markerId: MarkerId('Current location'),
            position: LatLng(userMap!['latitude'], userMap!['latitude']),
            infoWindow: InfoWindow(
                title: "You are here"
            ),
          ));
        }
        print(_usersLocations.length);
        _marker.addAll(_usersLocations);
        final List<Marker> allUserLocations = _marker;

      });
    });
    return _marker;
  }


  _initLocation() {
    _location?.getLocation().then((location) {
      _currentLocation = location;
    });
    _location?.onLocationChanged.listen((newLocation) {
      _currentLocation = newLocation;
    });
  }


  Future<LocationData?> _getCurrentLocation() async
  {
    var currentLocation = await _location?.getLocation();
    return currentLocation ?? null;
  }

  moveToCurrentLocation() async
  {
    LocationData? currentLocation = await _getCurrentLocation();
  }

  moveToPosition(LatLng latLng) async
  {
    GoogleMapController mapController = await _googleMapController.future;
    mapController.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
                target: latLng,
                zoom: 15)
        )
    );
  }

  //end of map functions

  //start of group functions

  void getAvailableGroups() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
        isLoading = false;
      });
    });
  }

  //end of group functions


  @override
  Widget build(BuildContext context) {
    bool lightmode = light1;
    Color? backgroundcolor = light1 ? Colors.grey[900] : Colors.white;
    Color textColor = light1 ? Colors.white : Colors.black;
    Color? cardColor = light1 ? Colors.grey[800] : Colors.grey[200];
    String darkmodeoption = light1 ? "Light mode" : "Dark mode";
    Color? navbarcolor = light1 ? Colors.grey[800] : Colors.grey[200];
    Color? iconcolor = light1 ? Colors.white70 : Colors.grey[800];
    Color? appbarcolor = light1 ? Colors.grey[800] : Colors.grey[200];
    final Size size = MediaQuery
        .of(context)
        .size;
    List<Marker> _allusersLocations = [];
    TextEditingController controller = TextEditingController();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: backgroundcolor,
        bottomNavigationBar: NavigationBar(
          backgroundColor: navbarcolor,
          onDestinationSelected: (int index) async {
            setState(() {
              currentPageIndex = index;
            });
            _usersLocations.clear();
            _marker.clear();

            await _firestore
                .collection('users')
                .doc(_auth.currentUser!.uid)
                .collection('My Users')
                .get()
                .then((value) {
              setState(() {
                print(value.docs.length);
                for(int i = 0; i < value.docs.length; i++)
                {
                  userMap = value.docs[i].data();
                  // print(userMap);
                  _usersLocations.add(Marker(
                    markerId: MarkerId('Current location'),
                    position: LatLng(userMap!['latitude'], userMap!['latitude']),
                    infoWindow: InfoWindow(
                        title: userMap!['Fullname']
                    ),
                  ));
                }
                _marker.addAll(_usersLocations);
              });
            });
          },
          indicatorColor: Colors.blue,
          selectedIndex: currentPageIndex,
          destinations: <Widget>[
            NavigationDestination(
              icon: Icon(Icons.map_rounded, color: iconcolor),
              label: 'Map',
            ),
            NavigationDestination(
              icon: Icon(Icons.phone, color: iconcolor),
              label: 'Phone',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble, color: iconcolor),
              label: "Chats",
            ),
            NavigationDestination(
              icon: Icon(Icons.group, color: iconcolor),
              label: 'Groups',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings, color: iconcolor),
              label: 'Settings',
            ),
          ],
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              var output = snapshot.data!.data();
              var statusValue = output!['Status'];
              var name = output!['Fullname'];

              return Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: backgroundcolor,

                body: <Widget>
                [
                  //map
                  Scaffold(
                    appBar: AppBar(
                      backgroundColor: appbarcolor,
                      automaticallyImplyLeading: false,
                      title: Text("Map", style: TextStyle(color: textColor)),
                    ),
                    body: _getMap(_marker),
                  ),

                  //calls
                  Scaffold(
                    backgroundColor: backgroundcolor,
                    appBar: AppBar(
                      backgroundColor: appbarcolor,
                      automaticallyImplyLeading: false,
                      title: Text("Calls", style: TextStyle(color: textColor)),
                    ),
                    body: buildMissedCalls1(),
                  ),

                  //chats
                  Scaffold(
                    appBar: AppBar(
                      backgroundColor: appbarcolor,
                      automaticallyImplyLeading: false,
                      title:
                          Text("Chats", style: TextStyle(color: textColor)),
                    ),
                    backgroundColor: backgroundcolor,
                    body: buildSelectedUsers(),
                    floatingActionButton: FloatingActionButton(
                      child: Icon(Icons.add),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddUsers(),
                        ),
                      ),
                      tooltip: "Add user",
                    ),
                  ),

                  //groups
                  Scaffold(
                    backgroundColor: backgroundcolor,
                    appBar: AppBar(
                      backgroundColor: appbarcolor,
                      automaticallyImplyLeading: false,
                      title: Text("Groups", style: TextStyle(color: textColor),),
                    ),
                    body: isLoading
                        ? Container(
                      height: size.height,
                      width: size.width,
                      alignment: Alignment.center,
                      child: Text("No groups created", style: TextStyle(color: textColor)),
                    )
                        : ListView.builder(
                      itemCount: groupList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: cardColor,
                          child: ListTile(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => GroupChatRoom(
                                    groupName: groupList[index]['name'],
                                    groupChatId: groupList[index]['id'],
                                  ),
                                ),
                              ),
                              leading: Icon(Icons.group, color: iconcolor),
                              title: Text(groupList[index]['name'], style: TextStyle(color: textColor)),
                            )
                        );
                        // return
                      },
                    ),
                    floatingActionButton: FloatingActionButton(
                      child: Icon(Icons.add),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddMembersInGroup(),
                        ),
                      ),
                      tooltip: "Create Group",
                    ),
                  ),

                  //settings
                  Scaffold(
                    appBar: AppBar(
                      backgroundColor: appbarcolor,
                      automaticallyImplyLeading: false,
                      title: Text("Settings", style: TextStyle(color: textColor),),
                    ),
                    backgroundColor: backgroundcolor,
                    body: Center(
                      child: Column(
                        children: [
                          Card(
                            color: cardColor,
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 16),
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundImage: NetworkImage(output!['profileImage']),
                              ),
                              title: Text(name.toString(),
                                style: TextStyle(
                                    height: 2, fontSize: 15, color: textColor),
                              ),
                              //status should be displayed here
                              subtitle: Text(statusValue.toString(),
                                style: TextStyle(
                                    height: 2, fontSize: 15, color: textColor),
                              ),
                            ),
                          ),

                          Card(
                            color: cardColor,
                            child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                title: Text('Edit Account Details',
                                    style: TextStyle(color: textColor)),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditPage(onTap: () {}, cardColor: cardColor, textColor: textColor, navbarcolor: navbarcolor, appbarcolor: appbarcolor),
                                    ),
                                  );
                                }
                            ),
                          ),

                          //status
                          Card(
                            color: cardColor,
                            child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                title: Text('Change Status',
                                    style: TextStyle(color: textColor)),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          StatusPage(onTap: () {},),
                                    ),
                                  );
                                }
                            ),
                          ),

                          Card(
                            color: cardColor,
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              title: Text(darkmodeoption,
                                  style: TextStyle(color: textColor)),
                              onTap: () {
                                setState(() {
                                  if (light1 == true) {
                                    light1 = false;
                                    users.doc(user.uid).update({"darkmode": false})
                                        .then((value) => print("Changed to light"))
                                        .catchError((onError) => print("Update failed..."));
                                  }
                                  else {
                                    light1 = true;
                                    users.doc(user.uid).update({"darkmode": true})
                                        .then((value) => print("Changed to dark"))
                                        .catchError((onError) => print("Update failed..."));
                                  }
                                });
                              },
                            ),
                          ),

                          Card(
                            color: cardColor,
                            child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                title: Text('Logout',
                                    style: TextStyle(color: textColor)),
                                onTap: () {
                                  signOut();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          LoginPage(onTap: () {},),
                                    ),
                                  );
                                }
                            ),
                          ),
                        ],
                      )
                    )
                  ),

                ][currentPageIndex],
              );
            }
        )
    );
  }


  Widget buildSelectedUsers()
  {
    _marker.clear();
    _usersLocations.clear();
    Color textColor = light1 ? Colors.white : Colors.black;
    myUsers.clear();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(_auth.currentUser?.uid).collection('My Users').snapshots(),
      builder: (context, snapshot) {

        if (snapshot.hasError) {
          return Text('error', style: TextStyle(color: Colors.black));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        print("Loading...");
        var docs = snapshot.data!.docs;
        if(docs.isEmpty)
        {
          return Text("No users added.", style: TextStyle(color: textColor, fontSize: 25));
        }
        else if(snapshot.data == null)
        {
          return Text("No data unavailable");
        }
        else
        {
          return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildSelectedUserListItem(doc))
              .toList(),
          );
        }
      },
    );
  }

  Widget _buildSelectedUserListItem(DocumentSnapshot document) {
    Color backgroundcolor = light1 ? Colors.black : Colors.white;
    Color textColor = light1 ? Colors.white : Colors.black;
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    Color? cardColor = light1 ? Colors.grey[800] : Colors.grey[200];
    String reguser, retrieveduser = '';

    if (_auth.currentUser!.email != data['email']) {
      return Card(
        color: cardColor,
        child: ListTile(
            leading: data['image'] != "" ? CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(data['image']),
            ) : CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage("https://cdn-icons-png.freepik.com/512/12225/12225935.png"),
            ),
            title: Text(data['Fullname'], style: TextStyle(color: textColor),),
            subtitle: Text(data['Status'], style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatPage(
                          receiverUserEmail: data['email'],
                          receiverUserID: data['uid'],
                          receiverUserName: data['Fullname'],
                          receiverUserStatus: data['Status'],
                        ),
                  )
              );
            },
            onLongPress: ()
            {
              //remove the user
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                      content: const Text("Select an action below"),
                      actions: <Widget>
                      [
                        TextButton(
                          onPressed: () => Navigator.pop(context, "NO"),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            print('on it...');
                            _firestore.collection('users').doc(_auth.currentUser?.uid).collection('My Users').doc(data!['uid']).delete();
                            // print(data!['uid']);
                            Navigator.pop(context, "NO");
                            // print(_auth.currentUser?.email);
                          },
                          child: const Text("Remove user"),
                        ),
                      ]
                  )
              );
              // print(data['Fullname']);
            },
        ),
      );

    }
    else {
      return Container();
    }
  }


  Widget buildMissedCalls1()
  {
    Color backgroundcolor = light1 ? Colors.black : Colors.white;
    Color textColor = light1 ? Colors.white : Colors.black;
    // Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    Color? cardColor = light1 ? Colors.grey[800] : Colors.grey[200];
    String myUsers = "";
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('Missed calls').orderBy("Time called", descending: false).snapshots(),
      builder: (context, snapshot) {
        var docs = snapshot.data!.docs;
        if(docs.isEmpty)
        {
          return Text("You have no missed calls or calls made.", style: TextStyle(color: textColor, fontSize: 18),);
        }
        else if(snapshot.data == null)
        {
          return Text("No data unavailable");
        }
        else
        {
          return ListView(
            children: snapshot.data!.docs
                .map<Widget>((doc) => buildMissedCalls2(doc))
                .toList(),
          );
        }
      },
    );
  }

  Widget buildMissedCalls2(DocumentSnapshot document) {
    Color backgroundcolor = light1 ? Colors.black : Colors.white;
    Color textColor = light1 ? Colors.white : Colors.black;
    Color? cardColor = light1 ? Colors.grey[800] : Colors.white;

    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users')
            .doc(user.uid).collection('Missed calls').doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          var output = snapshot.data!.data();
          var name = output!['Name'];
          var timecalled = output!['Time called'];

          return Card(
            color: cardColor,
              child: ListTile(
                leading: CircleAvatar(
                radius: 28,
                  backgroundImage: NetworkImage(output!['image']),
                ),
                title: Text(name.toString(), style: TextStyle(color: textColor),),
                subtitle: Row(
                  children: [
                    Text(timecalled.toString(), style: TextStyle(color: textColor)),
                    Text("          " + output!['In or Out'], style: TextStyle(color: textColor)),
                  ],
                ),
                  onTap: () async {
                  await FlutterPhoneDirectCaller.callNumber(output!['Phone']);
                },
              ),
            );
        }
    );
  }

  Marker _getUserLocationMarker()
  {
    return Marker(
        markerId: MarkerId('1'),
        position: LatLng(_cameraPosition!.target.latitude, _cameraPosition!.target.longitude),
        infoWindow: InfoWindow(
            title: "My current location 1"
        ),
    );
  }

  Widget _getMap(List<Marker> _allUserLocations) {
    List<Marker> _usersLocations = _allUserLocations;
    _marker.add(Marker(
      markerId: MarkerId('1'),
      position: LatLng(_cameraPosition!.target.latitude, _cameraPosition!.target.longitude),
      infoWindow: InfoWindow(
          title: "You are here"
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueBlue,
      )
      )
    );


    return GoogleMap(
      initialCameraPosition: _cameraPosition!,
      mapType: MapType.normal,
      markers: Set<Marker>.of(_marker),
      onMapCreated: (GoogleMapController controller) {
        if (!_googleMapController.isCompleted) {
          _googleMapController.complete(controller);
        }
      },
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blue,
              ),
              child: Column(
                children: [
                  Text(
                    chatMap['sendBy'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: size.height / 200,
                  ),
                  Text(
                    chatMap['message'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              )),
        );
      } else if (chatMap['type'] == "img") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            height: size.height / 2,
            child: Image.network(
              chatMap['message'],
            ),
          ),
        );
      } else if (chatMap['type'] == "notify") {
        return Container(
          width: size.width,
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black38,
            ),
            child: Text(
              chatMap['message'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        return SizedBox();
      }
    });
  }
}