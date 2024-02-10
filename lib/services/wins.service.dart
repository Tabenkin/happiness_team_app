import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happiness_team_app/helpers/functions.helpers.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/services/auth.service.dart';

class WinsService {
  static streamUserWins() {
    var uid = AuthService.currentUid;

    return FirebaseFirestore.instance
        .collection('/users/$uid/wins')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Win.fromMap(fromSnapshot(doc));
      }).toList();
    });
  }
}
