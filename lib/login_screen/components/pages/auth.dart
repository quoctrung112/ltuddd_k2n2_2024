import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Xử lý lỗi đăng ký, có thể hiển thị thông báo hoặc log lỗi
      print("Lỗi đăng ký: $e");
      rethrow;
    }
  }
}
