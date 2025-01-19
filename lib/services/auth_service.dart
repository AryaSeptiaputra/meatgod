import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream untuk mendengarkan perubahan status autentikasi
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Mendapatkan user saat ini
  User? get currentUser => _auth.currentUser;

  // Cek status login
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Login dengan email dan password serta penyaringan berdasarkan role
  Future<Map<String, dynamic>?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ambil data user dari Firestore berdasarkan UID
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists) {
        final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Periksa role
        if (userData['role'] == 'admin') {
          return {'role': 'admin', 'user': userData};
        } else if (userData['role'] == 'user') {
          return {'role': 'user', 'user': userData};
        } else {
          throw Exception('Role tidak valid');
        }
      } else {
        throw Exception('Data pengguna tidak ditemukan di Firestore');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Register dengan email, password, name, dan role
  Future<void> registerUser({
    required String email,
    required String password,
    required String name,
    String role = 'user',
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Tambahkan data pengguna ke Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Verifikasi email
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }

  // Cek apakah email sudah diverifikasi
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }
}
