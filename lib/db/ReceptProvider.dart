import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReceptProvider with ChangeNotifier {
  Future<QuerySnapshot<Map<String, dynamic>>>? _recepti;
  DocumentSnapshot<Map<String, dynamic>>? _singleRecept;
  void readRecepti() {
    _recepti = FirebaseFirestore.instance.collection('recepti').get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> get recepti {
    return _recepti!;
  }

  Future<void> readSingleRecept(receptId) async {
    _singleRecept = await FirebaseFirestore.instance.collection('recepti').doc(receptId).get();
  }

  DocumentSnapshot<Map<String, dynamic>> get singleRecept {
    return _singleRecept!;
  }

  void favRecept(List<dynamic> receptFavorites, String receptId) async {
    bool isFav = false;
    receptFavorites.forEach((element) async {
      if (element == FirebaseAuth.instance.currentUser!.uid) {
        isFav = true;
      }
    });
    if (isFav) {
      await FirebaseFirestore.instance.collection('recepti').doc(receptId).update({
        'favorites': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      });
      notifyListeners();
    } else {
      await FirebaseFirestore.instance.collection('recepti').doc(receptId).update({
        'favorites': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
      });
      notifyListeners();
    }
    notifyListeners();
  }
}
