import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:chatmate/main.dart';
import 'package:chatmate/models/Models.dart';
import 'actions/types.dart';

class ChatState {
  //authentication state values
  final String? errMsg;
  final bool? isAuthenticated;
  final bool? regLoading;
  final bool? logLoading;
  final User? user;
  final List<UserData>? allUsers;
  final List<Map<String, dynamic>>? messages;

  //chat state values
  final String? activeUser;
  final String? activeRoom;

  ChatState(
      {this.user,
      this.errMsg,
      this.isAuthenticated,
      this.regLoading,
      this.logLoading,
      this.allUsers,
      this.activeUser,
      this.activeRoom,
      this.messages});

  ChatState copyWith(
      {String? errMsg,
      bool? isAuthenticated,
      User? user,
      List<UserData>? allUsers,
      String? activeUser,
      String? activeRoom,
      List<Map<String, dynamic>>? messages}) {
    return ChatState(
        errMsg: errMsg ?? this.errMsg,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        user: user ?? this.user,
        allUsers: allUsers ?? this.allUsers,
        activeUser: activeUser ?? this.activeUser,
        activeRoom: activeRoom ?? this.activeRoom,
        messages: messages ?? this.messages);
  }
}

//auth reducer
ChatState authReducer(ChatState state, dynamic action) {
  if (action is UpdateErrorAction) {
    return state.copyWith(errMsg: action.err);
  }

  if (action is UpdateUserAction) {
    return state.copyWith(user: action.user);
  }

  if (action is UpdateAllUsersActions) {
    return state.copyWith(allUsers: action.allUsers);
  }

  return state;
}

//chat reducer
ChatState chatreducer(ChatState state, dynamic action) {
  if (action is UpdateRoomActions) {
    return state.copyWith(activeRoom: action.roomID);
  }

  if (action is UpdateMessageAction) {
    List<Map<String, dynamic>> messages = state.messages!;

    //check for uniqueness
    dynamic msgChecker =
        messages.where((m) => m["_id"] == action.messages["_id"]);
    if (msgChecker.length > 0) {
    } else {
      messages.add(action.messages);
      return state.copyWith(messages: messages);
    }
  }

  if (action is UpdateDispatchedMessageAction) {
    List<Map<String, dynamic>> messages = List.of(store.state.messages!);
    messages.sort((a, b) {
      return (a["time"]).compareTo(b["time"]);
    });

    //check for uniqueness
    dynamic msgChecker =
        messages.where((m) => m["_id"] == action.message["_id"]);
    if (msgChecker.length > 0) {
    } else {
      messages.add(action.message);
      return state.copyWith(messages: messages);
    }
  }
  return state;
}

//reset reducer
ChatState resetReducer(ChatState state, dynamic action) {
  switch (action) {
    case Types.ClearError:
      return state.copyWith(errMsg: "");
    case Types.IsAuthenticated:
      return state.copyWith(isAuthenticated: true);
  }
  return state;
}

//combined reducer
final dynamic reducers =
    combineReducers<ChatState>([authReducer, chatreducer, resetReducer]);
