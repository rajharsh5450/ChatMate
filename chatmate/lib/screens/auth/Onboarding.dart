import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:chatmate/screens/auth/Register.dart';
import 'package:chatmate/store/actions/authActions.dart';

import '../../main.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final LocalStorage storage = new LocalStorage('localstorage_app');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/welcome.png"),
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    new Future.delayed(
      Duration(seconds: 1),
      () {
        store.dispatch(loadUser(store: store, context: context));
      },
    );
  }
}
