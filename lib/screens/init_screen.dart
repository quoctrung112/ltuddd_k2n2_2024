import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Trendique_TLU/screens/profile/account_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../login_screen/components/pages/login_page.dart';
import '../screens_adm/donfalse/donfalse.dart';
import '../screens_adm/donpass/donpass_screen.dart';
import '../screens_adm/home/home_screen_adm.dart';
import 'bill/bill_screen.dart';
import 'home/home_screen.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({Key? key}) : super(key: key);

  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  final user = FirebaseAuth.instance.currentUser;
  int _currentIndex = 0;
  Color inActiveIconColor = Color(0xFFB6B6B6);

  final List<Widget> _screens = [
    HomeScreen(),
    BillScreen(),
    AccountScreen(),
  ];
  final List<Widget> _screensAdm = [
    BillScreenadm(),
    CompletedOrdersScreen(),
    CancelledOrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: user!.email != 'admin@gmail.com' ?
      Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar:
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                label: 'Hóa đơn',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person,),
                label: 'Cá nhân',
              ),
            ],
            selectedItemColor: primaryColor,
          )
      ):Scaffold(
          appBar: AppBar(
            title: Text(
              'ADMIN',
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              // Thêm nút đăng xuất ở góc phải của AppBar
              IconButton(
                icon: Icon(Icons.logout,color: primaryColor,),
                onPressed: () async {
                  _showLogoutConfirmationDialog(context);
                },
              ),
            ],
          ),
          body: _screensAdm[_currentIndex],
          bottomNavigationBar:
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'All Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.checklist),
                label: 'Đơn pass',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cancel_presentation,),
                label: 'Đơn false',
              ),
            ],
            selectedItemColor: primaryColor,
          )
      ),
    );
  }
  void _showLogoutConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Đăng xuất"),
          content: Text("Bạn có chắc chắn muốn đăng xuất?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Không"),
            ),
            TextButton(
              onPressed: () async {
                // Clear "Remember Me" status
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('rememberMe', false);

                // Sign out the user
                await FirebaseAuth.instance.signOut();

                // Navigate to SignInScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: Text("Có"),
            ),
          ],
        );
      },
    );
  }
}


