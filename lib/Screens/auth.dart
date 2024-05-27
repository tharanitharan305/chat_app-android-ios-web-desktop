import 'dart:io';
import 'package:chat_app/Widget/ImagePicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  State<AuthScreen> createState() {
    return _AuthScreen();
  }
}

class _AuthScreen extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _email = '';
  var _password = '';
  var _username = '';
  File? pickedImage;
  var _isAuthenticating = false;
  void onsubmit() async {
    var _isValid = _form.currentState!.validate();
    if (!_isValid || !_isLogin && pickedImage == null) {
      return;
    }
    _form.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        final _userCretial = await _firebase.signInWithEmailAndPassword(
            email: _email, password: _password);
      } else {
        final userCretial = await _firebase.createUserWithEmailAndPassword(
            email: _email, password: _password);
        final storegeref = FirebaseStorage.instance
            .ref()
            .child('USER_IMAGES')
            .child('${userCretial.user!.uid}.jpg');
        await storegeref.putFile(pickedImage!);
        final _ImageUrl = await storegeref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCretial.user!.uid)
            .set({
          "username": _username,
          "image_url": _ImageUrl,
          "email": _email
        });
      }
    } //try
    on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed..'),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } //catch
  }

  var _isLogin = true;
  Widget build(context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin:
                    EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
                child: Image.asset('asserts/images/chat.png'),
              ),
              Card(
                elevation: 20,
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPicked: (PickedImage) {
                                pickedImage = PickedImage;
                              },
                            ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text('Username'),
                              ),
                              onSaved: (value) {
                                _username = value!;
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Enter atleast 4 characters';
                                }
                                return null;
                              },
                            ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'EMAIL'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _email = newValue!;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'PASSWORD'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Enter a valid Password length mustbe greater than 6';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _password = newValue!;
                            },
                          ),
                          if (_isAuthenticating)
                            Center(child: CircularProgressIndicator()),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: onsubmit,
                              style: ElevatedButton.styleFrom(
                                elevation: 10,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    topLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                              ),
                              child: Text(_isLogin ? 'LOGIN' : 'SIGN UP'),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'CREATE AN ACCOUNT'
                                  : 'I ALREADY HAVE AN ACCOUNT'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
