import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import "package:redux/redux.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatmate/models/Models.dart';
import 'package:chatmate/screens/auth/Login.dart';
import 'package:chatmate/screens/home/UsersList.dart';
import 'package:chatmate/store/actions/types.dart';
import 'package:chatmate/store/reducer.dart';
import 'dart:convert';

//load action
Future<void>? loadUser({Store<ChatState>? store, BuildContext? context}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? _token = prefs.getString("apiToken") ?? null;

  final url = Uri.parse("http://localhost:5000/login/user");
  Map<String, String> headers = {
    "Context-type": "application/json",
    "x-chatmate-token": _token!,
  };
  Response res = await get(url, headers: headers);
  final statusCode = res.statusCode;

  if (statusCode != 200) {
    prefs.remove("apiToken");

    await Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context!, MaterialPageRoute(builder: (context) => Login()));
    });
  }

  if (statusCode == 200) {
    dynamic body = json.decode(res.body);
    User user = User(id: body["id"], email: body["email"], name: body["name"]);

    store!.dispatch(new UpdateUserAction(user));
    await Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context!, MaterialPageRoute(builder: (context) => UserList()));
    });
  }
}

//login action
Future<void>? login(
    {Store<ChatState>? store,
    BuildContext? context,
    @required email,
    @required password}) async {
  final url = Uri.parse("http://localhost:5000/login");
  Map<String, String> headers = {"Content-type": "application/json"};
  String data = '{"email": "' + email + '", "password": "' + password + '"}';

  //local storage
  SharedPreferences prefs = await SharedPreferences.getInstance();

  Response res = await post(url, headers: headers, body: data);
  final statusCode = res.statusCode;

  if (statusCode != 200) {
    dynamic body = json.decode(res.body);
    if (body["msg"] != "") {
      prefs.remove("apiToken");
      store!.dispatch(new UpdateErrorAction(body["msg"]));
    }
  }

  if (statusCode == 200) {
    dynamic body = json.decode(res.body);
    if (body["user"] != null) {
      store!.dispatch(Types.ClearError);
      User user = User(
          email: body["user"]["email"],
          name: body["user"]["name"],
          id: body["user"]["_id"]);

      //dispatch to store user inside store state
      store.dispatch(new UpdateUserAction(user));

      //set token for localstorage
      String token = body["token"];
      await prefs.setString("apiToken", "$token");

      Navigator.pushReplacement(
          context!, MaterialPageRoute(builder: (context) => UserList()));
    }
  }
}

//register action
Future<void>? register(
    {Store<ChatState>? store,
    BuildContext? context,
    @required email,
    @required password,
    @required cpassword}) async {
  final url = Uri.parse("http://localhost:5000/users");
  Map<String, String> headers = {"Content-type": "application/json"};
  String data = '{"email": "' +
      email +
      '", "password": "' +
      password +
      '", "cpassword": ' +
      cpassword +
      '", "name": "' +
      generateName(email) +
      '"}';

  Response res = await post(url, headers: headers, body: data);
  final statusCode = res.statusCode;

  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (statusCode != 200) {
    dynamic body = json.decode(res.body);
    if (body["msg"] != "") {
      prefs.remove("apiToken");
      store!.dispatch(new UpdateErrorAction(body["msg"]));
    }
  }

  if (statusCode == 200) {
    dynamic body = json.decode(res.body);
    if (body["user"] != null) {
      store!.dispatch(Types.ClearError);
      User user = User(
          email: body["user"]["email"],
          name: body["user"]["name"],
          id: body["user"]["_id"]);
      String token = body["token"];

      //set token for localstorage
      await prefs.setString("apiToken", "$token");

      //dispatch to store user inside store state
      store.dispatch(new UpdateUserAction(user));

      await Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacement(
            context!, MaterialPageRoute(builder: (context) => UserList()));
      });
    }
  }
}

String generateName(String uMail) {
  return uMail.split("@")[0];
}
