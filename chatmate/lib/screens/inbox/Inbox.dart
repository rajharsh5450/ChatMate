import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:chatmate/main.dart';
import 'package:chatmate/models/Models.dart';
import 'package:chatmate/store/actions/chatActions.dart';
import 'package:chatmate/store/actions/types.dart';
import 'package:chatmate/store/reducer.dart';
import 'package:socket_io_client/socket_io_client.dart';

class Inbox extends StatefulWidget {
  final String? senderMe;
  final String? reciever;

  const Inbox({Key? key, @required this.senderMe, @required this.reciever})
      : super(key: key);

  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  Socket? socket;
  // String? senderMe;
  // String? reciever;

  String _txtMsg = "";

  var txtController = TextEditingController();

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

      //dispatch on a chat
      store.dispatch(
        onUniqueChat(
            store: store,
            socket: socket,
            senderEmail: widget.senderMe,
            recieverEmail: widget.reciever),
      );

      //load unique chat related to room/user
      store.dispatch(
        loadUniqueChats(
          currentUserEmail: store.state.user!.email,
          otherUserEmail: widget.reciever,
          socket: socket,
          store: store,
        ),
      );

      //group unique chats related to room/user
      store.dispatch(
        groupUniqueChats(
          store: store,
          socket: socket,
        ),
      );

      //recieve messages from others
      socket!.on("dispatchMsg", (chats) {
        Map<String, dynamic> chat = new Map();
        chat["_id"] = chats["_id"];
        chat["roomID"] = chats["roomID"];
        chat["senderEmail"] = chats["senderEmail"];
        chat["recieverEmail"] = chats["recieverEmail"];
        chat["time"] = chats["time"];
        chat["txtMsg"] = chats["txtMsg"];
        chat["sender"] = chats["senderEmail"] == false;

        store.dispatch(new UpdateDispatchedMessageAction(chat));
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF1EA955),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'SA',
                  style: TextStyle(fontSize: 10),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "cUser",
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 2),
                child: Icon(
                  EvilIcons.user,
                  color: Colors.white,
                ),
              )
            ],
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {},
                child: Icon(
                  Ionicons.ios_videocam,
                  size: 30,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {},
                child: Icon(
                  FontAwesome.phone,
                  size: 30,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.more_vert,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            StoreConnector<ChatState, List<dynamic>>(
                builder: (_, msgs) {
                  return ListView.builder(
                      itemCount: msgs.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        bool sender = msgs[index]["sender"];
                        String txtmsg = msgs[index]["txtMsg"];

                        return Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Align(
                            alignment: (sender == true)
                                ? Alignment.topLeft
                                : Alignment.topRight,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              color: (sender == true)
                                  ? Color(0xFF1EA955)
                                  : Colors.grey.shade200,
                              padding: EdgeInsets.all(16),
                              child: Text(
                                txtmsg,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: (sender == true)
                                        ? Colors.white
                                        : Colors.black87),
                              ),
                            ),
                          ),
                        );
                      });
                },
                converter: (store) => store.state.messages!),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 10,
                ),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: [
                    GestureDetector(
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(30)),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextField(
                        controller: txtController,
                        decoration: InputDecoration(
                          hintText: "write a message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                        ),
                        onChanged: (textMsg) {
                          if (textMsg.length > 0) {
                            setState(() {
                              _txtMsg = textMsg;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        //dispatch the message
                        store.dispatch(
                          onSend(
                            socket: socket,
                            store: store,
                            recieverEmail: widget.reciever,
                            senderEmail: widget.senderMe,
                            txtmsg: _txtMsg,
                          ),
                        );

                        setState(() {
                          _txtMsg = "";
                        });

                        txtController.clear();
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      backgroundColor: Colors.blue,
                      elevation: 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //reset user's inbox
    store.state.messages!.clear();

    socketServer();
  }
}
