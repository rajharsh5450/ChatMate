// Start from 1:13 on vlc for video-part 1

import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:chatmate/screens/auth/Login.dart';
import 'package:chatmate/screens/auth/Onboarding.dart';
import 'package:chatmate/store/reducer.dart';
import 'package:flutter_redux/flutter_redux.dart';

// Initial state/store values
final store = new Store(reducers,
    initialState: ChatState(
      errMsg: "",
      isAuthenticated: false,
      allUsers: [],
      activeUser: "",
      activeRoom: "",
      messages: [],
    ),
    middleware: [thunkMiddleware]);

Future<void> main() async {
  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<ChatState>? store;

  MyApp({this.store});

  @override
  Widget build(BuildContext context) {
    return new StoreProvider(
        store: store!,
        child: MaterialApp(
            title: 'Flutter chatmate App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            initialRoute: "onboarding",
            routes: {
              "onboarding": (BuildContext context) => Onboarding(),
              //"login": (BuildContext context) => Login(),
            },
            home: SafeArea(
              child: Scaffold(),
            )));
  }
}
