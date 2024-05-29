import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionController extends GetxController {
  var offerings = Rxn<Offerings>();
  var isSubscribed = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOfferings();
    restorePurchasesAndCheckSubscriptionStatus();
  }

  Future<void> fetchOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      this.offerings.value = offerings;
    } on PlatformException catch (e) {
      // Handle error fetching offerings
    }
  }

  Future<void> restorePurchasesAndCheckSubscriptionStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      isSubscribed.value = customerInfo.entitlements.active.isNotEmpty;

      // if (isSubscribed.value) {
      //   Get.snackbar("Success",
      //       "Your purchases have been restored and you are subscribed.");
      // } else {
      //   Get.snackbar("Info", "No active subscriptions found.");
      // }
    } on PlatformException catch (e) {
      // Handle error restoring purchases
      Get.snackbar("Error", "Failed to restore purchases.");
    }
  }

  Future<void> purchasePackage(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      isSubscribed.value = customerInfo.entitlements.active.isNotEmpty;
      Get.snackbar("😍", "Purchased Successfully.");
    } on PlatformException catch (e) {
      // Handle error during purchase
      Get.snackbar("Error", "Failed to purchase.");
    }
  }
}

class SubscriptionPage extends StatelessWidget {
  final SubscriptionController controller = Get.put(SubscriptionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Obx(() {
        if (controller.offerings.value == null) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 84,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  textAlign: TextAlign.start,
                  'Get',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  textAlign: TextAlign.start,
                  'Luca Pro',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                height: 42,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  textAlign: TextAlign.start,
                  '✔️ Get Ad-Free access to Luca. \n✔️ Access to Premium Categories\n✔️ Unlock 1000+ wallpapers \n✔️ Wallpaper edit Functionality',
                  style: GoogleFonts.kanit(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                  children: [
                    if (controller.offerings.value?.current != null)
                      ...controller.offerings.value!.current!.availablePackages
                          .map(
                            (package) => Container(
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white.withOpacity(0.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 16.0),
                                title: Text(
                                  package.storeProduct.title,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0),
                                ),
                                subtitle: Text(
                                  package.storeProduct.description,
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                trailing: Text(
                                  package.storeProduct.priceString,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0),
                                ),
                                onTap: () =>
                                    controller.purchasePackage(package),
                              ),
                            ),
                          )
                          .toList(),
                    if (controller.isSubscribed.value)
                      Card(
                        color: Colors.lime,
                        elevation: 4.0,
                        margin: EdgeInsets.only(bottom: 16.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          title: Text(
                            "You are subscribed",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                        ),
                      ),
                    if (!controller.isSubscribed.value)
                      ElevatedButton(
                        onPressed: () {
                          if (controller.offerings.value?.current != null &&
                              controller.offerings.value!.current!
                                  .availablePackages.isEmpty) {
                            // Show alert if no purchases found
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("No Purchases Found"),
                                  content: Text(
                                      "You haven't made any purchases yet."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // Restore purchases
                            controller
                                .restorePurchasesAndCheckSubscriptionStatus();
                          }
                        },
                        child: Text(
                          "Restore Purchases",
                          style: TextStyle(fontSize: 16.0),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 32.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                      height: 58,
                      child: Text(
                        'May be later',
                        style: GoogleFonts.kanit(
                          color: Colors.white,
                          fontSize: 18,
                          decoration: TextDecoration.underline,
                        ),
                      )),
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}
