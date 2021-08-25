import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:localstorage/localstorage.dart';
import 'package:chatmate/main.dart';
import 'package:chatmate/screens/auth/Login.dart';
import 'package:chatmate/store/actions/authActions.dart';
import 'package:chatmate/store/reducer.dart';

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RegisterMain(),
    );
  }
}

class RegisterMain extends StatefulWidget {
  const RegisterMain({Key? key}) : super(key: key);

  @override
  _RegisterMainState createState() => _RegisterMainState();
}

class _RegisterMainState extends State<RegisterMain> {
  String _email = "";
  String _password = "";
  String _cpassword = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/bgmain.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 100),
                    padding: EdgeInsets.only(left: 52, right: 52, bottom: 10),
                    width: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/Register.png"),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    child: SizedBox(
                      height: 100,
                      child: null,
                    ),
                  ),
                  StoreConnector<ChatState, String>(
                    converter: (store) => store.state.errMsg!,
                    onWillChange: (prev, next) {},
                    builder: (_, errMsg) {
                      return Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          "$errMsg",
                          style: TextStyle(
                            color: Color(0xffff4500),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 2),
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: TextField(
                            onChanged: (email) {
                              setState(() {
                                if (email.length > 0) {
                                  _email = email;
                                }
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xffC4C4C4),
                                  width: 2,
                                ),
                              ),
                              hintText: "email@domain.com",
                              hintStyle: TextStyle(fontSize: 15),
                            ),
                            textCapitalization: TextCapitalization.none,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: TextField(
                            onChanged: (password) {
                              setState(() {
                                if (password.length > 0) {
                                  _password = password;
                                }
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xffC4C4C4),
                                  width: 2,
                                ),
                              ),
                              hintText: "Password of minimum length 6.",
                              hintStyle: TextStyle(fontSize: 15),
                            ),
                            textCapitalization: TextCapitalization.none,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: TextField(
                            onChanged: (password) {
                              setState(() {
                                if (password.length > 0) {
                                  _cpassword = password;
                                }
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xffC4C4C4),
                                  width: 2,
                                ),
                              ),
                              hintText: "confirm your password.",
                              hintStyle: TextStyle(fontSize: 15),
                            ),
                            textCapitalization: TextCapitalization.none,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(25),
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: TextButton(
                            onPressed: () {
                              store.dispatch(register(
                                  store: store,
                                  context: context,
                                  email: _email,
                                  password: _password,
                                  cpassword: _cpassword));
                            },
                            style: TextButton.styleFrom(
                              primary: Colors.red,
                              backgroundColor: Color(0xff474EF4),
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 15),
                            ),
                            child: Text(
                              "Register",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(25),
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()),
                              );
                            },
                            style: TextButton.styleFrom(
                              primary: Colors.red,
                              backgroundColor: Color(0xFFFFFFFF),
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 15),
                            ),
                            child: Text(
                              "Already have an account? Login Here.",
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
