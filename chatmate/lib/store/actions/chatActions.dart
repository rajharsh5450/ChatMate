import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatmate/main.dart';
import 'package:chatmate/store/actions/types.dart';
import 'package:chatmate/store/reducer.dart';
import 'package:uuid/uuid.dart';

import 'package:socket_io_client/socket_io_client.dart';

Future<void>? onUniqueChat(
    {Store<ChatState>? store,
    Socket? socket,
    @required senderEmail,
    @required recieverEmail}) async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  dynamic uniqueRoomsGetter = pref.get("_uniqueRooms");
  dynamic uniqueRooms =
      (uniqueRoomsGetter == null) ? [] : json.decode(uniqueRoomsGetter);

  socket!.emit("startUniqueChat", {
    'senderEmail': senderEmail,
    'recieverEmail': recieverEmail,
  });

  socket.on("openChat", (chat) {
    Map<String, String> mobileRoom = new Map();
    mobileRoom["recieverEmail"] = chat['recieverEmail'];
    mobileRoom["senderEmail"] = chat['senderEmail'];
    mobileRoom["roomID"] = chat['roomID'];

    if (uniqueRooms.length > 0) {
      //if uniquechats contain a chat in this current room from database
      // or else add it to unique rooms
      dynamic list =
          uniqueRooms.where((chats) => chats["roomID"] == chat["roomID"]);

      Future.delayed(Duration(microseconds: 2));

      if (list.length == 0) {
        uniqueRooms.add(mobileRoom);

        //push new room to localstorage
        pref.setString("_uniqueRooms", json.encode(uniqueRooms));

        //start peer to peer new chat
        socket.emit("joinTwoUsers", {'roomID': chat["roomID"]});

        //update active room
        store!.dispatch(new UpdateRoomActions(chat["roomID"]));
      }
    } else {
      uniqueRooms.add(mobileRoom);

      //push new room to localstorage
      pref.setString("_uniqueRooms", json.encode(uniqueRooms));

      //update active room
      store!.dispatch(new UpdateRoomActions(chat["roomID"]));

      //start peer to peer new chat
      socket.emit("joinTwoUsers", {'roomID', chat["roomID"]});
    }
  });
}

Future<void>? onSend(
    {Store<ChatState>? store,
    Socket? socket,
    String? txtmsg,
    String? senderEmail,
    String? recieverEmail}) async {
  if (txtmsg == "") {
  } else {
    final now = new DateTime.now();
    dynamic formattedTime = DateTime.now().toUtc().microsecondsSinceEpoch;

    //message construction and pushing to messages
    Map<String, dynamic> composeMsg = new Map();
    composeMsg["_id"] = Uuid().v4();
    composeMsg["roomID"] = store!.state.activeRoom;
    composeMsg["txtMsg"] = txtmsg;
    composeMsg["recieverEmail"] = recieverEmail;
    composeMsg["senderEmail"] = senderEmail;
    composeMsg["time"] = formattedTime;
    composeMsg["sender"] = true;

    store.dispatch(new UpdateMessageAction(composeMsg));

    //emit to reciever
    socket!.emit("sendToUser", composeMsg);
  }
}

Future<void>? loadUniqueChats(
    {Store<ChatState>? store,
    Socket? socket,
    @required currentUserEmail,
    @required otherUserEmail}) async {
  Map<String, dynamic> chatDetails = new Map();
  chatDetails["senderEmail"] = currentUserEmail;
  chatDetails["recieverEmail"] = otherUserEmail;

  socket!.emit("load_user_chats", chatDetails);
}

Future<void> groupUniqueChats({Store<ChatState>? store, Socket? socket}) async {
  var uniqueMessages;
  socket!.on("loadUniqueChat", (chats) {
    List<dynamic>? uniqueMessages = [];
    if (chats.isEmpty) {
      return;
    } else {
      Map<String, dynamic> chat = new Map();
      chat["_id"] = chats["_id"];
      chat["roomID"] = chats["roomID"];
      chat["senderEmail"] = chats["senderEmail"];
      chat["recieverEmail"] = chats["recieverEmail"];
      chat["time"] = chats["time"];
      chat["txtMsg"] = chats["txtMsg"];
      chat["sender"] = chats["senderEmail"] == store!.state.user!.email;

      //push to messages
      store.dispatch(new UpdateMessageAction(chat));
    }
  });
}
