import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static User? _currentUser;

  static Future<User?> signIn(String email, String password) async {
    try {
      final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (authResult.user != null) {
        _currentUser = await _getUserFromFirestore(authResult.user!.uid);
      }
      
      return _currentUser;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  static Future<User?> signUp(String name, String email, String password) async {
    try {
      final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (authResult.user != null) {
        final newUser = User(
          id: authResult.user!.uid,
          name: name,
          email: email,
        );
        
        await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());
        _currentUser = newUser;
      }
      
      return _currentUser;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
  }

  static User? getCurrentUser() {
    return _currentUser;
  }

  static Future<User?> _getUserFromFirestore(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    
    if (!userDoc.exists) {
      return null;
    }
    
    return User.fromMap(userDoc.data()!, userDoc.id);
  }

  static Future<void> initializeAuth() async {
    final currentFirebaseUser = _firebaseAuth.currentUser;
    if (currentFirebaseUser != null) {
      _currentUser = await _getUserFromFirestore(currentFirebaseUser.uid);
    }
  }
}
