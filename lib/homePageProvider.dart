// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
//
// class HomePageProvider extends ChangeNotifier {
//
//   String? geName;
//   String? geEmail;
//   Uint8List? image;
//
//   Future<void> getData() async {
//
//     var data = await Hive.openBox('Zahid');
//     geName = data.get('name')?.toString();
//     geEmail = data.get('email')?.toString();
//     image = data.get('image');
//     notifyListeners();
//   }
//
//   Future<void> insertData(String name, String email, Uint8List? imageBytes) async {
//     var box = await Hive.openBox('Zahid');
//     box.put('name', name);
//     box.put('email', email);
//     if (imageBytes != null) {
//       box.put('image', imageBytes);
//     }
//     await getData();
//   }
// }

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class User {
  String? name;
  String? email;
  Uint8List? image;

  User({this.name, this.email, this.image});
}

class HomePageProvider extends ChangeNotifier {
  List<User> _users = [];

  List<User> get users => _users;

  Future<void> getData() async {
    var data = await Hive.openBox<dynamic>('Zahid');
    // Clear existing data
    _users.clear();
    // Iterate over the keys in the box and add users to the list
    for (var key in data.keys) {
      _users.add(
        User(
          name: data.get(key)['name']?.toString(),
          email: data.get(key)['email']?.toString(),
          image: data.get(key)['image'],
        ),
      );
    }
    notifyListeners();
  }

  Future<void> insertData(String name, String email, Uint8List? imageBytes) async {
    var box = await Hive.openBox<dynamic>('Zahid');
    int index = box.keys.isEmpty ? 0 : box.keys.map((e) => int.parse(e.toString())).reduce((value, element) => value > element ? value : element) + 1;
    box.put(index.toString(), {'name': name, 'email': email, 'image': imageBytes});
    await getData();
  }

  Future<void> deleteData(int index) async {
    var box = await Hive.openBox<dynamic>('Zahid');
    await box.deleteAt(index);
    await getData();
    notifyListeners();// Refresh data after deletion
  }

  Future<void> updateData(int index, String name, String email, Uint8List? imageBytes) async {
    var box = await Hive.openBox<dynamic>('Zahid');
    if (box.containsKey(index.toString())) {
      box.put(index.toString(), {'name': name, 'email': email, 'image': imageBytes});
      await getData();
      notifyListeners();
    }
  }
}
