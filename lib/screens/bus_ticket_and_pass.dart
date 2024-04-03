import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BusTicketing extends StatefulWidget {
  final bool isTicket;

  const BusTicketing({super.key, required this.isTicket});

  @override
  State<BusTicketing> createState() => _BusTicketingState();
}

class _BusTicketingState extends State<BusTicketing> {
  TextEditingController stationFrom = TextEditingController();
  TextEditingController stationTo = TextEditingController();
  TextEditingController durationController = TextEditingController();
  late bool isTicket;
  bool payWithGoogleButton = false;

  @override
  void initState() {
    isTicket = widget.isTicket;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green,
                  Colors.lightGreenAccent,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const Text(
                        "Hello, Rahul",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    isTicket
                        ? "Book Your Local Bus Ticket"
                        : "Book Your Local Bus Pass",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 30),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  isTicket ? buildTicketingContainer() : buildPassContainer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  buildTicketingContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSwitchingContainer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  "From",
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  // height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      border: const Border.fromBorderSide(
                        BorderSide(color: Colors.black12, width: 1),
                      ),
                      borderRadius: BorderRadius.circular(16)),
                  child: TextField(
                    controller: stationFrom,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.green,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  )),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  "To",
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                // height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    border: const Border.fromBorderSide(
                      BorderSide(color: Colors.black12, width: 1),
                    ),
                    borderRadius: BorderRadius.circular(16)),
                child: TextField(
                  controller: stationTo,
                  cursorColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.green,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  "Fare",
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                // height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    border: const Border.fromBorderSide(
                      BorderSide(color: Colors.black12, width: 1),
                    ),
                    borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "10",
                      style: TextStyle(fontSize: 24, color: Colors.green),
                    ),
                    Text(
                      "Rs.",
                      style: TextStyle(fontSize: 24, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    payWithGoogleButton = !payWithGoogleButton;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10, top: 10),
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Continue",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (kDebugMode) {
                    print("--------------------> Google pay...");
                  }
                },
                child: Visibility(
                  visible: payWithGoogleButton,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10, top: 10),
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: const Border.fromBorderSide(
                        BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/googleLogo.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          "Pay with Google",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buildPassContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSwitchingContainer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  "From",
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  // height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      border: const Border.fromBorderSide(
                        BorderSide(color: Colors.black12, width: 1),
                      ),
                      borderRadius: BorderRadius.circular(16)),
                  child: TextField(
                    controller: stationFrom,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.green,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  )),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  "To",
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  // height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      border: const Border.fromBorderSide(
                        BorderSide(color: Colors.black12, width: 1),
                      ),
                      borderRadius: BorderRadius.circular(16)),
                  child: TextField(
                    controller: stationTo,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.green,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  )),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  "Duration",
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  // height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      border: const Border.fromBorderSide(
                        BorderSide(color: Colors.black12, width: 1),
                      ),
                      borderRadius: BorderRadius.circular(16)),
                  child: TextField(
                    controller: durationController,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.green,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter duration (in month)",
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                    ),
                    keyboardType: TextInputType.number,
                  )),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  "Fare",
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                // height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    border: const Border.fromBorderSide(
                      BorderSide(color: Colors.black12, width: 1),
                    ),
                    borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "10",
                      style: TextStyle(fontSize: 24, color: Colors.green),
                    ),
                    Text(
                      "Rs.",
                      style: TextStyle(fontSize: 24, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    payWithGoogleButton = true;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10, top: 10),
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Continue",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (kDebugMode) {
                    print("--------------------> Google pay...");
                  }
                },
                child: Visibility(
                  visible: payWithGoogleButton,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10, top: 10),
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: const Border.fromBorderSide(
                        BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/googleLogo.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          "Pay with Google",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buildSwitchingContainer() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: const Border.fromBorderSide(
          BorderSide(
            width: 1,
            color: Colors.grey,
          ),
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isTicket = true;
                  clearControl();
                });
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: isTicket ? Colors.green : Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                    child: Text(
                  "Ticket",
                  style: TextStyle(color: Colors.white),
                )),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isTicket = false;
                  clearControl();
                });
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: isTicket ? Colors.grey.withOpacity(0.5) : Colors.green,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text(
                    "Pass",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void clearControl() {
    stationTo.clear();
    stationFrom.clear();
    payWithGoogleButton = false;
  }
}
