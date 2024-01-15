import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../models/constructions.dart' as construction2;
import '../models/localisation.dart';

class MongoHelpers {
  MongoHelpers._privateConstructor();

  static final MongoHelpers instance = MongoHelpers._privateConstructor();

  late Db _db;

  Future<void> connect() async {
    _db = await Db.create(
        'mongodb+srv://ayoub:1234@cluster3.huhgkmb.mongodb.net/flutterpro?retryWrites=true&w=majority');
    await _db.open();
  }

  Future<void> disconnect() async {
    await _db.close();
  }

  /////////////
  // late final Db db;
  // static DbCollection? _collection;
  // static MongoHelpers? _instance;

  // MongoHelpers._(); // Private constructor

  // static Future<MongoHelpers> getInstance() async {
  //   if (_instance == null) {
  //     _instance = MongoHelpers._();
  //     await _instance!._init();
  //   }
  //   return _instance!;
  // }

  // Future<void> _init() async {
  //   db = await Db.create(
  //       "mongodb+srv://ayoub:1234@cluster3.huhgkmb.mongodb.net/flutterpro?retryWrites=true&w=majority");
  //   await db.open();
  //   _collection = db.collection('constructions');
  // }

  //////////

  // //final Db db;
  // late final Db db;

  // static DbCollection? _collection;

  // // MongoHelpers() {
  // //   //this.db
  // //   _init();
  // // }
  // MongoHelpers();

  // Future<void> init() async {
  //   //_init
  //   var db = await Db.create(
  //       "mongodb+srv://ayoub:1234@cluster3.huhgkmb.mongodb.net/flutterpro?retryWrites=true&w=majority");
  //   await db.open();
  //   _collection = db.collection('constructions');
  // }

  // DbCollection get collection {
  //   if (_collection == null) {
  //     throw StateError('MongoDB collection has not been initialized yet.');
  //   }
  //   return _collection!;
  // }

  // Converts a MongoDB document to a Construction object
  Localization _documentToLocalisation(Map<String, dynamic> document) {
    return Localization.fromMap(document);
  }

  // Converts a Construction object to a MongoDB document
  Map<String, dynamic> _localisationToDocument(Localization localisation) {
    return localisation.toMap();
  }

  // CRUD Method - Create
  Future<void> create(Localization localization) async {
    try {
      await _db
          .collection('localizations')
          .insertOne(_localisationToDocument(localization));
      print('Document inserted successfully.');
    } catch (e) {
      print('Error inserting document: $e');
    }
  }

  // CRUD Method - Read (All documents)
  Future<List<Localization>> readAll() async {
    try {
      var documents = await _db.collection('localizations').find().toList();
      print(documents);

      return documents.map(_documentToLocalisation).toList();
    } catch (e) {
      print('Error fetching constructions: $e');
      return []; // Return an empty list or handle the error as appropriate
    }
  }

  Future<List<Map<String, dynamic>>> readAllforUser() async {
    try {
      // Get the current user
      final User? user = FirebaseAuth.instance.currentUser;

      // Ensure the user is not null
      if (user == null) {
        print('No user is signed in.');
        return [];
      }

      // Get the user's name
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Get the user's name
      final String userName = userDoc['name'] ?? '';
      print("the user name is $userName");

      // Fetch documents where the 'name' field matches the user's name
      var documents = await _db
          .collection('localizations')
          .find({'name': userName}).toList();
      print(documents);

      return documents;
    } catch (e) {
      print('Error fetching constructions: $e');
      return []; // Return an empty list or handle the error as appropriate
    }
  }

  // CRUD Method - Create User
  Future<void> createUser(Map<String, dynamic> document) async {
    try {
      await _db.collection('users').insertOne((document));
      print('Document inserted successfully.');
    } catch (e) {
      print('Error inserting document: $e');
    }
  }

  Future<void> insertConstruction(
      construction2.Construction construction) async {
    await _db.collection("constructionsAgent").insert(construction.toMap());
  }

  Future<List<Map<String, dynamic>>> readAllConstructions() async {
    var results = await _db.collection("constructionsAgent").find().toList();
    return results.map((result) => result).toList();
  }

  // Fetch user names from the 'users' collection
  Future<List<String>> fetchUserNames() async {
    try {
      var documents = await _db.collection('users').find().toList();
      return documents.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      print('Error fetching user names: $e');
      return []; // Return an empty list or handle the error as appropriate
    }
  }
  // CRUD Method - Read (Document by ID)
//   Future<Construction?> readById(ObjectId id) async {
//     var document = await collection.findOne(where.id(id));
//     if (document != null) {
//       return _documentToConstruction(document);
//     }
//     return null;
//   }

//   // CRUD Method - Update
//   Future<void> update(ObjectId id, Construction updatedConstruction) async {
//     await collection.replaceOne(
//         where.id(id), _constructionToDocument(updatedConstruction));
//   }

//   // CRUD Method - Delete
//   Future<void> delete(ObjectId id) async {
//     await collection.deleteOne(where.id(id));
//   }
// }
}

//import 'package:mongo_dart/mongo_dart.dart';

