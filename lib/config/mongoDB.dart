import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:public_transit_pass_info/config/constant.dart';

class MongoDatabase {
  Future<String> fetchUserPassNumber(String aadharNum) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    try {
      var collection = db.collection(PASS_DETAILS_COLLECTION);
      var userQuery = {"aadharNumber": aadharNum};
      var userDetail = await collection.findOne(userQuery);
      if (kDebugMode) {
        print("*********************************************************");
        print("Pass number : ${userDetail?['passNumber']}");
        print("*********************************************************");
      }
      return userDetail?['passNumber'];
    } catch (ex) {
      if (kDebugMode) {
        print("*********************************************************");
        print("Error while fetching userPassNumber : ${ex.toString()}");
        print("*********************************************************");
        return "Data Not found";
      }
    } finally {
      await db.close();
    }
    return "Data Not found";
  }

  Future<bool?> checkTCDetails(String fullName, String idNumber) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    try {
      var collection = db.collection(TC_DETAILS_COLLECTION);
      var userQuery = {"name": fullName, "employee_no": idNumber};
      var userDetail = await collection.findOne(userQuery);
      if (kDebugMode) {
        print("*********************************************************");
        print(
            "TC full name and idNumber from mongoDB.dart : ${userDetail?['name']} and ${userDetail?['employee_no']}");
        print("*********************************************************");
      }
      return userDetail?.isNotEmpty;
    } catch (ex) {
      if (kDebugMode) {
        print("*********************************************************");
        print(
            "Error while fetching checking the TC Details : ${ex.toString()}");
        print("*********************************************************");
        return false;
      }
    } finally {
      await db.close();
    }
    return false;
  }

  Future<bool?> isVerifiedTCDetails(String email) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    try {
      var collection = db.collection(USER_DETAILS_COLLECTION);
      var userQuery = {"email": email};
      var userDetail = await collection.findOne(userQuery);

      if (userDetail != null) {
        // Check if the user is a TC (isTC field is true)
        bool? isTC = userDetail['isTC'];
        return isTC ?? false; // If isTC is null, default to false
      } else {
        // User not found with the given email
        return false;
      }
    } catch (ex) {
      if (kDebugMode) {
        print("*********************************************************");
        print("Error while fetching isTC true or false : ${ex.toString()}");
        print("*********************************************************");
        return false;
      }
    } finally {
      await db.close();
    }
    return false;
  }

  static Future<List<Map<String, dynamic>>> fetchUserDetails(
      String email, String dbCollection) async {
    var db = await Db.create(MONGO_URL);
    await db.open();

    try {
      var collection = db.collection(dbCollection);
      var userQuery = {"email": email};
      var userData = await collection.findOne(userQuery);
      if (userData != null) {
        // Return user data as a list containing one user
        return [userData];
      } else {
        // Return an empty list if the user is not found
        return [];
      }
    } catch (error) {
      // Handle errors and return an empty list
      if (kDebugMode) {
        print(error.toString());
      }
      return [];
    } finally {
      await db.close();
    }
  }

  Future<String?> findReferralCodeByEmail(
      String email, String dbCollection) async {
    final db = await Db.create(MONGO_URL);
    await db.open();
    final collection = db.collection(dbCollection);
    final result = await collection.findOne(where.eq('email', email));
    await db.close();

    if (result != null && result.containsKey('referralCode')) {
      return result['referralCode'] as String?;
    } else {
      return null; // Return null if the email or referralCode is not found
    }
  }

  static Future<dynamic> saveUserData(
      Map<String, dynamic> userData, var dbCollection) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    try {
      var collection = db.collection(dbCollection);
      await collection.insert(userData);
      return userData['email'].toString();
    } catch (ex) {
      if (kDebugMode) {
        print(ex.toString());
      }
    } finally {
      await db.close();
    }
  }

  static Future<void> deleteUserData(
      Map<String, dynamic> userData, var dbCollection) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var collection = db.collection(dbCollection);
    await collection.deleteOne(userData);
    db.close();
  }

  Future<void> updateUserData(String userUID, String userName, String firstName,
      String lastName, String contactNum, String aadhaarNum) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    try {
      var collection = db.collection(USER_DETAILS_COLLECTION);

      // Define the update query
      var selector = where.eq('userUID', userUID);

      // Define the new values to update
      var modifier = {
        r'$set': {
          'username': userName,
          'firstName': firstName,
          'lastName': lastName,
          'contactNum': contactNum,
          'aadhaarNum': aadhaarNum,
        }
      };

      // Perform the update operation
      await collection.update(selector, modifier);

      if (kDebugMode) {
        print('User data updated successfully.');
      }
    } catch (ex) {
      // Handle exceptions
      if (kDebugMode) {
        print('Error updating user data: $ex');
      }
    } finally {
      // Close the database connection
      await db.close();
    }
  }

  static connect() async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    // inspect(db);
    // var status = db.serverStatus();
    // if (kDebugMode) {
    //   print(status);
    // }
    // var collection = db.collection(USER_DETAILS_COLLECTION);
    // if (kDebugMode) {
    //   print(await collection.find().toList());
    // }
  }


  Future<bool> checkAadhaarNumPresence() async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    User? user = FirebaseAuth.instance.currentUser;
    try {
      var collection = db.collection(USER_DETAILS_COLLECTION);
      var selector = where.eq('userUID', user!.uid);
      var userDoc = await collection.findOne(selector);

      if (userDoc != null && userDoc.containsKey('aadhaarNum')) {
        // Aadhaar number exists in the user document
        var aadhaarNum = userDoc['aadhaarNum'];
        if (aadhaarNum != null && aadhaarNum.isNotEmpty) {
          // Aadhaar number is present and not empty
          // getPassDetails();
          return true;
        }
      }

      // Aadhaar number not found or is empty
      return false;
    } catch (ex) {
      // Handle exceptions
      if (kDebugMode) {
        print('Error while checking the presence of Aadhaar number: $ex');
      }
      return false;
    } finally {
      // Close the database connection
      await db.close();
    }
  }


}

// to update call the function like this
// Map<String, dynamic> selector = {"username": "existingUsername"};
// Map<String, dynamic> modifier = {
//   "\$set": {"name": "newName", "email": "newEmail@gmail.com"}
// };
// await MongoDatabase.updateUserData(selector, modifier, "yourCollectionName");
