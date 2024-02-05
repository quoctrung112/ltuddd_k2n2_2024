import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth.dart';
String? email;
String? password;
String? conform_password;

class SignUpForm extends StatefulWidget {
  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;


  List<String> _errors = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đăng ký"),
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
                buildPasswordFormField(),
                const SizedBox(height: 16),
                buildConfirmPasswordFormField(),
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
                        bool otpSent = await sendOTPToEmail(email!, password!);

                        if (otpSent) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Thư xác thực đã được gửi đến email của bạn. Vui lòng kiểm tra hộp thư và xác thực tài khoản."),
                              duration: Duration(seconds: 5),
                            ),
                          );

                          // Navigate back to the previous screen
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Gửi email thất bại. Vui lòng thử lại."),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
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
                  child: Text("Đăng ký"),
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
      onSaved: (newValue) => email = newValue,
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        fillColor: Colors.grey.shade200,
        filled: false,
        hintText: 'Nhập email',
        hintStyle: TextStyle(color: Colors.grey[500]),
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


  TextFormField buildPasswordFormField() {
    return TextFormField(
      onSaved: (newValue) => password = newValue,
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        fillColor: Colors.grey.shade200,
        filled: false,
        hintText: 'Nhập mật khẩu',
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "Vui lòng nhập mật khẩu";
        } else if (value.length < 6) {
          return "Mật khẩu quá ngắn";
        }
        return null;
      },
    );
  }

  TextFormField buildConfirmPasswordFormField() {
    return TextFormField(
      onSaved: (newValue) => conform_password = newValue,
      controller: _confirmPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        fillColor: Colors.grey.shade200,
        filled: false,
        hintText: 'Nhập lại mật khẩu',
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "Vui lòng nhập xác nhận mật khẩu";
        } else if (_passwordController.text != value) {
          return "Mật khẩu không khớp";
        }
        return null;
      },
    );
  }

  Future<bool> sendOTPToEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _auth.currentUser?.sendEmailVerification();
      return true;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
