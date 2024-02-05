import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _errors = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quên Mật Khẩu"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                buildEmailFormField(),
                const SizedBox(height: 16),
                _errors.isNotEmpty
                    ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    _errors.join('\n'),
                    style: TextStyle(color: Colors.red),
                  ),
                )
                    : const SizedBox.shrink(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      try {
                        await resetPassword(_emailController.text.trim());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Thư reset mật khẩu đã được gửi đến email của bạn. Vui lòng kiểm tra hộp thư để đặt lại mật khẩu.",
                            ),
                            duration: Duration(seconds: 5),
                          ),
                        );

                        // Navigate back to the previous screen
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Lỗi: $e"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  child: Text("Đặt Lại Mật Khẩu"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "Nhập email của bạn",
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "Vui lòng nhập email";
        } else if (!EmailValidator.validate(value)) {
          return "Email không hợp lệ";
        }
        return null;
      },
    );
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
