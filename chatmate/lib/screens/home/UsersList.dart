import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatmate/main.dart';
import 'package:chatmate/models/Models.dart';
import 'package:chatmate/screens/inbox/Inbox.dart';
import 'package:chatmate/store/actions/types.dart';
import 'package:chatmate/store/reducer.dart';
import 'package:socket_io_client/socket_io_client.dart';

class UserList extends StatelessWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ChatAppList(),
    );
  }
}

class ChatAppList extends StatefulWidget {
  const ChatAppList({Key? key}) : super(key: key);

  @override
  _ChatAppListState createState() => _ChatAppListState();
}

class _ChatAppListState extends State<ChatAppList> {
  Socket? socket;

  //connecting to socket
  void socketServer() {
    try {
      //initialise and connect to socket
      socket = io("http://localhost:5000", <String, dynamic>{
        "transports": ['websocket'],
        "autoConnect": false,
      });
      socket!.connect();

      //handle socket events
      socket!.on('connect', (data) => {print("connect: ${socket!.id}")});
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF1EA955),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 10,
              child: Text(
                "BS",
                style: TextStyle(fontSize: 10),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Samuel",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () {},
                  child: Icon(
                    FontAwesome.phone,
                    size: 30,
                  ),
                ),
              )
            ],
          ),
          body: Container(
            child: Column(
              children: [
                StoreConnector<ChatState, List<UserData>>(
                  builder: (_, allUsers) {
                    if (allUsers.length < 1) {
                      return Container(
                        child: Center(
                          child: Text("Loading users"),
                        ),
                      );
                    }

                    //current user
                    User user = store.state.user!;

                    return Container(
                      padding: EdgeInsets.only(top: 10),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: allUsers.length,
                          itemBuilder: (BuildContext context, int index) {
                            // String userName= allUsers[index].name!.split("@");

                            return InkWell(
                              splashColor: null,
                              onTap: () {
                                socket!.close();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Inbox(
                                            reciever: allUsers[index].email,
                                            senderMe: user.email,
                                          )),
                                );
                              },
                              child: Ink(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: null,
                                    child: Text(
                                      allUsers[index]
                                          .name!
                                          .substring(0, 2)
                                          .toUpperCase(),
                                    ),
                                  ),
                                  title: Text(allUsers[index].name!),
                                  subtitle: Text(
                                    allUsers[index].name! + " is on ChatMate",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  trailing: Column(
                                    children: [Text("date")],
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  ),
                                ),
                              ),
                            );
                          }),
                    );
                  },
                  converter: (store) => store.state.allUsers!,
                  onWillChange: (prev, next) {},
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    socketServer();

    //emit to get all other users except current one
    User currUser = store.state.user!;
    socket!.emit("_getUsers");

    //store them to state
    socket!.on("_allUsers", (allUsers) {
      List<UserData> users = [];
      for (var u in allUsers) {
        UserData _user =
            UserData(name: u["name"], email: u["email"], id: u["id"]);
        if (u["email"] != currUser.email) {
          users.add(_user);
        }
      }

      store.dispatch(new UpdateAllUsersActions(users));
    });
  }
}
