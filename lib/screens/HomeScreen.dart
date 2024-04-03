import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:public_transit_pass_info/config/palette.dart';
import 'package:public_transit_pass_info/screens/bus_ticket_and_pass.dart';
import 'package:public_transit_pass_info/screens/train_ticket_and_pass.dart';

// import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Provider/userProvider.dart';
import '../config/constant.dart';
import '../config/mongoDB.dart';
import '../config/notificatoinServices.dart';
import 'NotificationScreen.dart';
import 'SignInAndSignUpScreen.dart';
import 'my_profile.dart';

class HomeScreen extends StatefulWidget {
  final userId;
  final asTC;

  const HomeScreen({super.key, required this.userId, required this.asTC});

  @override
  State<StatefulWidget> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  bool isTrain = true;
  late var userId;
  late List<Map<String, dynamic>> userData = [];
  TextEditingController searchText = TextEditingController();
  NotificationServices notificationServices = NotificationServices();
  // MobileScannerController cameraController = MobileScannerController();
  final MongoDatabase dbServices = MongoDatabase();
  late String qrData = '';
  bool isTrainPassAvailable = false;
  bool isBusPassAvailable = false;
  List<Map<String, dynamic>> userPassDetails = [];
  bool _isAadhaarNumPresent = false;
  bool showScanner = false;
  bool isTicket = true;
  late dynamic scanValue;
  bool isScanCompleted = false;

  @override
  initState() {
    super.initState();
    _initializeScreen();
    notificationServices.initLocalNotification();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit();
    getQRData();
    Future.delayed(Duration.zero, () {
      userId = widget.userId.toString();
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      userProvider.setUserId(userId); // Ensure userData is not null
      userProvider.setUserData();
      if (kDebugMode) {
        print("****************************************");
        getUserData();
        print("UserInHomeID: $userId");
        print("as Admin: ${widget.asTC}");
        print("****************************************");
      }
      // notificationServices.requestNotificationPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat.yMMMMd('en_US').format(now);
    var screenSize = MediaQuery.of(context).size;
    var isLandScape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    double verticalInternalPadding =
        isLandScape ? screenSize.height * 0.03 : screenSize.height * 0.03;
    double horizontalInternalPadding =
        isLandScape ? screenSize.width * 0.02 : screenSize.width * 0.05;
    double componentContainerSize =
        isLandScape ? screenSize.width * 0.15 : screenSize.width * 0.25;

    return Scaffold(
      backgroundColor:
          isTrain ? palette.trainThemeColor : palette.busThemeColor,
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.all(horizontalInternalPadding * 0.8),
            child: Column(
              children: [
                // Intro and Notification with Menu Icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Hello, ${userData.isNotEmpty ? userData[0]['username'] : ''}",
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isTrain
                                ? palette.trainComponantColor
                                : palette.busComponantColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NotificationScreen()));
                                if (kDebugMode) {
                                  print('Notice');
                                }
                              },
                              child: const Icon(
                                Icons.notifications,
                                size: 30,
                                color: Colors.white,
                              )),
                        ),
                        SizedBox(
                          width: horizontalInternalPadding,
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isTrain
                                ? palette.trainComponantColor
                                : palette.busComponantColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                              onTap: () {
                                if (kDebugMode) {
                                  print('Menu');
                                }
                                showMenu(context);
                              },
                              child: const Icon(
                                Icons.menu,
                                size: 30,
                                color: Colors.white,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: horizontalInternalPadding,
                ),
                // Search Bar
                Container(
                  width: screenSize.width,
                  height: isLandScape
                      ? screenSize.height / 8
                      : screenSize.height / 18,
                  decoration: BoxDecoration(
                    color: isTrain
                        ? palette.trainComponantColor
                        : palette.busComponantColor,
                    borderRadius: BorderRadius.circular(12),
                    border: const Border.fromBorderSide(
                        BorderSide(color: Colors.white30)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: horizontalInternalPadding / 2,
                      ),
                      Icon(
                        Icons.search,
                        size: isLandScape
                            ? screenSize.width * 0.035
                            : screenSize.width * 0.08,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: horizontalInternalPadding / 2,
                      ),
                      Expanded(
                          child: TextField(
                        controller: searchText,
                        cursorColor: isTrain
                            ? palette.trainThemeColor
                            : palette.busThemeColor,
                        cursorOpacityAnimates: true,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          hintText: "Search...",
                          hintStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w300),
                          border: InputBorder.none,
                        ),
                      )),
                    ],
                  ),
                ),
                SizedBox(
                  height: horizontalInternalPadding,
                ),
                // Train and Bus Pass Data Presentation
                widget.asTC
                    ? Container(
                        width: screenSize.width,
                        height: isLandScape
                            ? screenSize.height * 0.50
                            : screenSize.height * 0.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 12,
                            ),
                            Container(
                              width: double.infinity,
                              height: screenSize.height * 0.06,
                              color: isTrain
                                  ? Colors.blue.shade400.withOpacity(0.5)
                                  : Colors.green.withOpacity(0.5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: isTrain
                                    ? MainAxisAlignment.spaceAround
                                    : MainAxisAlignment.start,
                                children: [
                                  Text(
                                    isTrain ? "Indian Railway" : '',
                                    style: isTrain
                                        ? const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900)
                                        : null,
                                  ),
                                  Image.asset(
                                    isTrain
                                        ? 'assets/images/Indian_Railways.png'
                                        : 'assets/images/bus_Logo_for_TC.png',
                                    fit: BoxFit.fitWidth,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: RichText(
                                          text: const TextSpan(
                                              text: "Name: ",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.normal),
                                              children: [
                                            TextSpan(
                                                text: "Rahul Prajapati",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ])),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          RichText(
                                              text: const TextSpan(
                                                  text: "Designation: ",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                  children: [
                                                TextSpan(
                                                    text: "TC/CC",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ])),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, left: 8),
                                      child: RichText(
                                          text: const TextSpan(
                                              text: "DOB: ",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.normal),
                                              children: [
                                            TextSpan(
                                                text: "20-09-2002",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ])),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, left: 8),
                                      child: RichText(
                                          text: const TextSpan(
                                              text: "Date of issue: ",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.normal),
                                              children: [
                                            TextSpan(
                                                text: "31-01-2024",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ])),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, left: 8),
                                      child: RichText(
                                          text: const TextSpan(
                                              text: "Date of expiry: ",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.normal),
                                              children: [
                                            TextSpan(
                                                text: "31-10-2025",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ])),
                                    ),
                                  ],
                                ),
                                Image.asset('assets/images/femaleAvatar.gif'),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Container(
                        width: screenSize.width,
                        height: isLandScape
                            ? screenSize.height * 0.50
                            : screenSize.height * 0.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isAadhaarNumPresent
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: screenSize.height * 0.06,
                                    color: isTrain
                                        ? Colors.deepOrange.shade400
                                            .withOpacity(0.8)
                                        : Colors.green.withOpacity(0.5),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment: isTrain
                                          ? MainAxisAlignment.spaceAround
                                          : MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          isTrain ? "Mumbai Local Train" : "",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w900),
                                        ),
                                        Image.asset(
                                          isTrain
                                              ? 'assets/images/trainLogo.png'
                                              : 'assets/images/bus_Logo_for_TC.png',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8, top: 8),
                                            child: RichText(
                                                text: TextSpan(
                                                    text: "Name: ",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                    children: [
                                                  TextSpan(
                                                      text: userPassDetails[0]
                                                          ['passengerName'],
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ])),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8, top: 8),
                                            child: RichText(
                                                text: TextSpan(
                                                    text: "From: ",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                    children: [
                                                  TextSpan(
                                                      text: userPassDetails[0]
                                                          ['from'],
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ])),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8, left: 8),
                                            child: RichText(
                                                text: TextSpan(
                                                    text: "To: ",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                    children: [
                                                  TextSpan(
                                                      text: userPassDetails[0]
                                                          ['to'],
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ])),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8, left: 8),
                                            child: RichText(
                                                text: TextSpan(
                                                    text: "Class: ",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                    children: [
                                                  TextSpan(
                                                      text: userPassDetails[0]
                                                          ['class'],
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ])),
                                          ),
                                        ],
                                      ),
                                      Image.asset(
                                          'assets/images/maleAvatar.gif'),
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 8, left: 20),
                                    child: RichText(
                                        text: TextSpan(
                                            text: "Valid from: ",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                            children: [
                                          TextSpan(
                                              text: userPassDetails[0]
                                                  ['activationDate'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          const TextSpan(
                                              text: "  To  ",
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.normal)),
                                          TextSpan(
                                              text: userPassDetails[0]
                                                  ['ExppiryDate'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ])),
                                  ),
                                ],
                              )
                            : const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(50.0),
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                      "Pass Details Not Available!! If you have Pass then fill the Profile details to fetch."),
                                ),
                              ),
                      ),
                SizedBox(
                  height: horizontalInternalPadding,
                ),
                // Cards in row
                SizedBox(
                  width: screenSize.width,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          width: componentContainerSize,
                          height: componentContainerSize,
                          padding: EdgeInsets.all(verticalInternalPadding / 2),
                          margin: EdgeInsets.only(
                              right: isLandScape
                                  ? horizontalInternalPadding * 2
                                  : horizontalInternalPadding / 2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isTrain
                                  ? palette.trainComponantColor
                                  : palette.busComponantColor),
                          child: InkWell(
                            onTap: () {
                              if (isTrain) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const TrainTicketing(
                                                isTicket: true)));
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BusTicketing(
                                                isTicket: true)));
                              }
                            },
                            child: Image.asset(
                              isTrain
                                  ? 'assets/images/trainTicket.png'
                                  : 'assets/images/busTicket.png',
                            ),
                          ),
                        ),
                        Container(
                          width: componentContainerSize,
                          height: componentContainerSize,
                          padding: EdgeInsets.all(verticalInternalPadding / 2),
                          margin: EdgeInsets.only(
                              right: isLandScape
                                  ? horizontalInternalPadding * 2
                                  : horizontalInternalPadding / 2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isTrain
                                  ? palette.trainComponantColor
                                  : palette.busComponantColor),
                          child: InkWell(
                            onTap: () async {
                              if (isTrain) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const TrainTicketing(
                                                isTicket: false)));
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BusTicketing(
                                                isTicket: false)));
                              }
                            },
                            child: Image.asset(
                              isTrain
                                  ? 'assets/images/trainPass.png'
                                  : 'assets/images/busPass.png',
                            ),
                          ),
                        ),
                        Container(
                          width: componentContainerSize,
                          height: componentContainerSize,
                          padding: EdgeInsets.all(verticalInternalPadding / 2),
                          margin: EdgeInsets.only(
                              right: isLandScape
                                  ? horizontalInternalPadding * 2
                                  : horizontalInternalPadding / 2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isTrain
                                  ? palette.trainComponantColor
                                  : palette.busComponantColor),
                          // child: InkWell(
                          //   onTap: () {},
                          //   child: Image.asset(
                          //     isTrain
                          //         ? 'assets/images/trainTicket.png'
                          //         : 'assets/images/busTicket.png',
                          //   ),
                          // ),
                        ),
                        Container(
                          width: componentContainerSize,
                          height: componentContainerSize,
                          padding: EdgeInsets.all(verticalInternalPadding / 2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isTrain
                                  ? palette.trainComponantColor
                                  : palette.busComponantColor),
                          // child: InkWell(
                          //   onTap: () {},
                          //   child: Image.asset(
                          //     isTrain
                          //         ? 'assets/images/trainPass.png'
                          //         : 'assets/images/busPass.png',
                          //   ),
                          // ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: horizontalInternalPadding,
                ),
                // QR container
                Container(
                  width: screenSize.width,
                  height: screenSize.height * 0.4,
                  padding: EdgeInsets.all(horizontalInternalPadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // color: isTrain ? palette.trainComponantColor : palette.busComponantColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.white30,
                          blurRadius: 20,
                          spreadRadius: 2)
                    ],
                  ),
                  child: widget.asTC
                      ? showScanner
                          ? Stack(
                              children: [
                                // MobileScanner(
                                //   controller: cameraController,
                                //   allowDuplicates: true,
                                //   onDetect: (capture, args) {
                                //     try{
                                //       if (!isScanCompleted) {
                                //         scanValue = capture.rawValue ?? '---';
                                //         if (kDebugMode) {
                                //           print(
                                //               "-------------------------------> $scanValue");
                                //         }
                                //         isScanCompleted = true;
                                //         if (isScanCompleted) {
                                //           setState(() {
                                //             showScanner = false;
                                //           });
                                //         }
                                //       }
                                //     }catch(ex){
                                //       if (kDebugMode) {
                                //         print("Error while Scanning -------------------> ${ex.toString()}");
                                //       }
                                //     }
                                //   },
                                // ),



                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(
                                          () {
                                            showScanner = false;
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.black,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Center(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showScanner = true;
                                  });
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => const Scanner()));
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.6),
                                          blurRadius: 8,
                                          blurStyle: BlurStyle.outer)
                                    ],
                                  ),
                                  child: const Text(
                                    "Verify Passenger",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            )
                      : Center(
                          child: !isTrainPassAvailable
                              ? Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.8),
                                          blurRadius: 10,
                                          blurStyle: BlurStyle.outer),
                                    ],
                                  ),
                                  child: QrImageView(
                                    data: userPassDetails[0]['passNumber'],
                                    version: QrVersions.auto,
                                    size: 200.0,
                                  ),
                                )
                              : const Text(
                                  "Pass Not Available",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 24),
                                ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showMenu(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            shadowColor: Colors.black,
            content: SizedBox(
              // width: MediaQuery.of(context).size.height * 0.8,
              height: MediaQuery.of(context).size.height * 0.3,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox.shrink(),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.cancel_outlined,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyProfile()));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black,
                                  blurStyle: BlurStyle.outer,
                                  spreadRadius: 2,
                                  blurRadius: 5)
                            ],
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/maleAvatar.gif',
                                height: 50,
                                width: 50,
                              ),
                              const Text(
                                "Edit Profile",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            isTrain = !isTrain;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black,
                                  blurStyle: BlurStyle.outer,
                                  spreadRadius: 2,
                                  blurRadius: 5)
                            ],
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                isTrain
                                    ? 'assets/images/trainLogo.png'
                                    : 'assets/images/busLogo.png',
                                height: 50,
                                width: 50,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text(
                                "Mode",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          FirebaseAuth.instance.signOut().then((value) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignInAndSignUpScreen()));
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black,
                                  blurStyle: BlurStyle.outer,
                                  spreadRadius: 2,
                                  blurRadius: 5)
                            ],
                          ),
                          child: const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Icon(
                                  Icons.exit_to_app,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Sign Out",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            backgroundColor:
                isTrain ? Colors.lightBlueAccent : Colors.lightGreenAccent,
            // actions: [
            //   InkWell(
            //     onTap: () {
            //       Navigator.pop(context);
            //     },
            //     child: Text(
            //       actionText!,
            //       style: const TextStyle(fontSize: 16),
            //     ),
            //   ),
            // ],
          );
        });
  }

  Future<void> getUserData() async {
    userData =
        await MongoDatabase.fetchUserDetails(userId!, USER_DETAILS_COLLECTION);
    setState(() {});
    if (kDebugMode) {
      print(
          "*********************************************************************");
      print('User Data in Home: $userData');
      print(
          "*********************************************************************");
    }
  }

  switchMode() {
    setState(() {
      isTrain = !isTrain;
      _initializeScreen();
    });
  }

  Future<String> getQRData() async {
    qrData = await dbServices
        .fetchUserPassNumber(userPassDetails[0]['aadharNumber']);
    if (kDebugMode) {
      print(
          "*********************************>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<");
      print(qrData);
      print(
          "*********************************>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<");
    }
    return qrData;
  }

  Future<void> _initializeScreen() async {
    bool isAadhaarPresent =
        await dbServices.checkAadhaarNumPresence(context) == true;
    setState(() {
      _isAadhaarNumPresent = isAadhaarPresent;
    });
    if (kDebugMode) {
      print(
          '>>>>>>>>>>>>>>>>>>>>>>>Presence of Aadhaar Number: $_isAadhaarNumPresent');
    }
    if (_isAadhaarNumPresent) {
      userPassDetails = await dbServices.getPassDetails();
      if (kDebugMode) {
        print(
            "<><><><><><><><><><><><><><> User Pass Details: $userPassDetails <><><><><><><><><><><><><><>");
      }
    }
    setState(() {});
  }
}
