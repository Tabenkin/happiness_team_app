import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

typedef Wins = List<Win>;

class Win {
  String? id;
  String userId;
  DateTime date;
  String notes;
  int lastViewedTimestamp;

  Win({
    this.id,
    required this.userId,
    required this.date,
    required this.notes,
    required this.lastViewedTimestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
      'lastViewedTimestamp': lastViewedTimestamp,
    };
  }

  factory Win.fromMap(Map<String, dynamic> map) {
    return Win(
      id: map['id'],
      userId: map['userId'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      notes: map['notes'],
      lastViewedTimestamp: map['lastViewedTimestamp'],
    );
  }

  String get formattedDate {
    const ordinals = ["th", "st", "nd", "rd"];
    int day = date.day;
    String ordinal =
        ordinals[(day < 20 && day > 3) ? 0 : (day % 10 < 4 ? day % 10 : 0)];

    String formattedDate = DateFormat('MMMM d').format(date); // "February 2"
    return "$formattedDate$ordinal ${date.year}"; // "February 2nd 2024"
  }

  save() async {
    var basePath = "/users/$userId/wins";

    if (id == null) {
      var response =
          await FirebaseFirestore.instance.collection(basePath).add(toMap());
      id = response.id;
    } else {
      await FirebaseFirestore.instance.doc('$basePath/$id').update(toMap());
    }
  }

  delete() async {
    var basePath = "/users/$userId/wins";

    await FirebaseFirestore.instance.collection(basePath).doc(id).delete();
  }
}
