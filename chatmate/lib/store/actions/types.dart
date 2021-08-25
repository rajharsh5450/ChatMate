//types of actions

import 'dart:ffi';

import 'package:chatmate/models/Models.dart';

enum Types { ClearError, ClearUser, ClearLog, ClearReg, IsAuthenticated }

//update error message
class UpdateErrorAction {
  String? _err;

  String get err => this._err!;

  UpdateErrorAction(this._err);
}

//update user action
class UpdateUserAction {
  User? _user;

  User get user => this._user!;

  UpdateUserAction(this._user);
}

//store all users and actions
class UpdateAllUsersActions {
  List<UserData>? _allUsers;

  get allUsers => this._allUsers;
  UpdateAllUsersActions(this._allUsers);
}

//update room actions
class UpdateRoomActions {
  String? _roomID;

  get roomID => this._roomID;

  UpdateRoomActions(this._roomID);
}

//add messages to chat
class UpdateMessageAction {
  Map<String, dynamic>? _messages;

  get messages => this._messages;

  UpdateMessageAction(this._messages);
}

//update with recent dispatched msg
class UpdateDispatchedMessageAction {
  Map<String, dynamic>? _messages;

  get message => this._messages;

  UpdateDispatchedMessageAction(this._messages);
}
