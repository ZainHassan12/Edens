import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edens_tech/string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../bottombar.dart';
import '../user_model.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController repassController = TextEditingController();

  final isPasswordVisible = true.obs;
  final isRepassVisible = true.obs;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    repassController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    final name = nameController.text;
    final email = emailController.text;
    final pass = passController.text;
    final repass = repassController.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty || repass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: golden,
          content: Text('Fill all fields', style: TextStyle(color: Colors.white),),
        ),
      );
      return;
    }

    if (pass != repass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match', style: TextStyle(color: Colors.white),),
        ),
      );
      return;
    }

    EasyLoading.show(status: "Please wait ...");

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);

      final user = userCredential.user;

      if (user != null) {
        await user.sendEmailVerification();
        UserModel userModel = UserModel(
          name: name,
          email: email,
          phone: '',
          userImg: '',
          country: '',
          userAddress: '',
          createdOn: DateTime.now(),
        );
        await FirebaseFirestore.instance.collection('user').doc(user.uid).set(userModel.toMap());

        if (user.emailVerified) {
          Get.off(const BottomBar());
        } else {
          Get.off(const VerifyEmail());
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: golden,
            content: Text('Account created successfully', style: TextStyle(color: Colors.white),),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: golden,
          content: Text(e.toString(), style: const TextStyle(color: Colors.white),),
        ),
      );
    }

    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(background),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(logo, width: 150),
                const SizedBox(height: 5),
                const Text(
                  "Join Now",
                  style: TextStyle(
                    color: golden,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: screenWidth * 0.78,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: golden,
                        blurRadius: 10,
                        offset: Offset(2, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Name",
                                style: TextStyle(
                                  fontFamily: semibold,
                                  fontSize: 15,
                                  color: golden,
                                ),
                              ),
                            ),
                            TextField(
                              style: const TextStyle(color: Colors.black),
                              controller: nameController,
                              decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                prefixIcon: const Icon(Icons.email),
                                hintText: "Enter Your Name",
                                border: const OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: golden),
                                ),
                              ),
                              maxLines: 1,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 15,)
                          ],
                        ),
                        Column(
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Email",
                                style: TextStyle(
                                  fontFamily: semibold,
                                  fontSize: 15,
                                  color: golden,
                                ),
                              ),
                            ),
                            TextField(
                              style: const TextStyle(color: Colors.black),
                              controller: emailController,
                              decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                prefixIcon: const Icon(Icons.email),
                                hintText: "Enter Email Address",
                                border: const OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: golden),
                                ),
                              ),
                              maxLines: 1,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 15,)
                          ],
                        ),
                        Column(
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Password",
                                style: TextStyle(
                                  fontFamily: semibold,
                                  fontSize: 15,
                                  color: golden,
                                ),
                              ),
                            ),
                            Obx(
                                  ()=> TextField(
                                style: const TextStyle(color: Colors.black),
                                controller: passController,
                                obscureText: isPasswordVisible.value,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.password),
                                  suffixIcon: GestureDetector(
                                    onTap: (){
                                      isPasswordVisible.toggle();
                                    },
                                    child: isPasswordVisible.value?
                                    const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
                                  ),
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: 'Enter Password',
                                  border: const OutlineInputBorder(),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: golden),
                                  ),
                                ),
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(height: 15,)
                          ],
                        ),
                        Column(
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Re-enter Password",
                                style: TextStyle(
                                  fontFamily: semibold,
                                  fontSize: 15,
                                  color: golden,
                                ),
                              ),
                            ),
                            Obx(
                                  ()=> TextField(
                                style: const TextStyle(color: Colors.black),
                                controller: repassController,
                                obscureText: isPasswordVisible.value,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.password),
                                  suffixIcon: GestureDetector(
                                    onTap: (){
                                      isPasswordVisible.toggle();
                                    },
                                    child: isPasswordVisible.value?
                                    const Icon(Icons.visibility_off) : const Icon(Icons.visibility),
                                  ),
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: 'Re-enter Password',
                                  border: const OutlineInputBorder(),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: golden),
                                  ),
                                ),
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(height: 15,)
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: golden,
                          ),
                          onPressed: _registerUser,
                          child: const Text(
                              "Signup",
                            style: TextStyle(
                              color: Colors.white
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                              "Back To Login",
                            style: TextStyle(
                              color: golden,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VerifyEmail extends StatelessWidget {
  const VerifyEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Verify your email address',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: golden,
              ),
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  try {
                    await user.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: golden,
                        content: Text('Verification email re-sent', style: TextStyle(color: Colors.white),),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: golden,
                        content: Text(e.toString(), style: const TextStyle(color: Colors.white),),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: golden,
                      content: Text('User not found', style: TextStyle(color: Colors.white),),
                    ),
                  );
                }
              },
              child: const Text(
                  'Resend Verification Email',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
