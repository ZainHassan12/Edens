import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edens_tech/authScreens/loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../string.dart';
import 'address_info.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late User _user;
  DocumentSnapshot<Map<String, dynamic>>? _userData;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userData = await FirebaseFirestore.instance
        .collection('user')
        .doc(_user.uid)
        .get();
    setState(() {
      _userData = userData;
      _nameController.text = _userData!['name'];
      _emailController.text = _userData!['email'];
      _phoneController.text = _userData!['phone'] ?? '';
    });
  }

  Future<void> _updateUserData() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(_user.uid)
        .update({
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile Updated Successfully'),
      ),
    );
  }

  Future<void> _editField(String fieldName, TextEditingController controller) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit $fieldName"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter $fieldName",
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateUserData();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Profile",
          style: TextStyle(fontFamily: semibold, color: Colors.white),
        ),
        toolbarHeight: screenHeight * 0.06,
        backgroundColor: golden,
        leading: Container(),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                userbg,
                width: screenWidth,
                height: screenHeight * 0.2,
                fit: BoxFit.cover,
              ),
              Container(
                margin: EdgeInsets.only(left: screenWidth * 0.03, top: screenHeight * 0.09),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.1,
                      backgroundColor: golden,
                      backgroundImage: _userData != null && _userData!['userImg'] != null
                          ? NetworkImage(_userData!['userImg'])
                          : const NetworkImage(
                        'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTl8fHBlcnNvbnxlbnwwfHwwfHx8MA%3D%3D',
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Text(
                      _userData != null && _userData!['name'] != null ? _userData!['name'] : 'Name',
                      style: TextStyle(
                        fontFamily: bold,
                        fontSize: screenHeight * 0.03,
                        color: golden,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            margin: EdgeInsets.only(top: screenHeight * 0.035),
            width: screenWidth,
            height: screenHeight * 0.5,
            decoration: BoxDecoration(
              color: Colors.white70,
              boxShadow: [
                BoxShadow(
                  color: golden.withOpacity(0.8),
                  blurRadius: 10,
                  offset: const Offset(2, 2),
                ),
              ],
              borderRadius: const BorderRadius.all(Radius.circular(3)),
            ),
            child: _userData != null
                ? Column(
              children: [
                ListTile(
                  title: const Text('Name'),
                  subtitle: Row(
                    children: [
                      Expanded(child: Text(_userData!['name'])),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editField('Name', _nameController);
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Email'),
                  subtitle: Row(
                    children: [
                      Expanded(child: Text(_userData!['email'])),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editField('Email', _emailController);
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Phone Number'),
                  subtitle: Row(
                    children: [
                      Expanded(child: Text(_userData!['phone'] ?? '')),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editField('Phone Number', _phoneController);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Logout"),
                          content: const Text(
                            "Are you sure you want to logout?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: golden),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                FirebaseAuth.instance.signOut().then((value) => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                ));
                              },
                              child: const Text(
                                "Logout",
                                style: TextStyle(color: golden),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
