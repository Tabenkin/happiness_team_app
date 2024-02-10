import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static Stream<User?> get onAuthStateChanges {
    return FirebaseAuth.instance.authStateChanges();
  }

  static bool get isUserLoggedIn {
    return FirebaseAuth.instance.currentUser != null;
  }

  static String get currentUid {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  static Future<UserCredential> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    return FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> signInAsGuest() async {
    return await FirebaseAuth.instance.signInAnonymously();
  }

  static logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
