import 'package:cloud_firestore/cloud_firestore.dart';

import './../models/message_model.dart';
import './../models/contact_model.dart';
import './../models/conversation_model.dart';

class DBService {
  static DBService instance = DBService();
  final String _userCollection = "Users";
  final String _conversationsCollection = "Conversations";

  FirebaseFirestore? _db;

  DBService() {
    _db = FirebaseFirestore.instance;
  }

  Future<void> createUser(
      String _uid, String _name, String _email, String _imageUrl) async {
    try {
      return await _db?.collection(_userCollection).doc(_uid).set({
        "name": _name,
        "email": _email,
        "image": _imageUrl,
        "lastSeen": DateTime.now().toUtc()
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void>? updateUserLastSeenTime(String _userID){
    var _ref = _db?.collection(_userCollection).doc(_userID);
    
    return _ref?.update({"lastSeen":Timestamp.now()});
  }

  Future<void> sendMessage(String _conversationID, Message _message){
    var _ref = _db?.collection(_conversationsCollection).doc(_conversationID);

    var _messageType = "";
    
    switch(_message.type){
      case MessageType.Text:
        _messageType = "text";
        break;
      case MessageType.Image:
        _messageType = "image";
        break;
    }
    
    return _ref!.update({
      "messages": FieldValue.arrayUnion([
        {
          "message": _message.content,
          "senderID": _message.senderID,
          "timestamp": _message.timestamp,
          "type": _messageType
        }
      ])
    });
  }

  Future<void>? updateLastseenCount(String _senderID, String _receiverID) async{
    var _ref = _db?.collection(_userCollection).doc(_receiverID).collection(_conversationsCollection).doc(_senderID);
    var _userConversationRef = await _ref?.get();


    return _ref?.update({"unseenCount":_userConversationRef!.data()?["unseenCount"]+1});
  }

  Future<void>? updateBothInfo(String _senderID, String _receiverID, String _message, MessageType _type) {
    var _senderRef = _db?.collection(_userCollection).doc(_senderID).collection(_conversationsCollection).doc(_receiverID);
    var _receiverRef = _db?.collection(_userCollection).doc(_receiverID).collection(_conversationsCollection).doc(_senderID);
    var _messageType = "";

    switch(_type){
      case MessageType.Text:
        _messageType = "text";
        break;
      case MessageType.Image:
        _messageType = "image";
        break;
    }

    _senderRef?.update({
      "lastMessage":_message,
      "type": _messageType,
      "timestamp":Timestamp.now()
    });
    _receiverRef?.update({
      "lastMessage":_message,
      "type": _messageType,
      "timestamp":Timestamp.now()
    });
  }

  Future<void>? resetUnseenCount(String _senderID, String _receiverID) {
    var _ref = _db?.collection(_userCollection).doc(_senderID).collection(_conversationsCollection).doc(_receiverID);

    return _ref?.update({"unseenCount":0});
  }

  Future<void> createOrGetConversation(String _currentID, String _recepientID,
    Future<void> _onSuccess(String _conversationID)) async {
      var _ref = _db?.collection(_conversationsCollection);
      var _senderConversationRef = _db?.collection(_userCollection).doc(_currentID).collection(_conversationsCollection);
      var _receiverConversationRef = _db?.collection(_userCollection).doc(_recepientID).collection(_conversationsCollection);
      var _senderRef = await _db?.collection(_userCollection).doc(_currentID).get();
      var _receiverRef = await _db?.collection(_userCollection).doc(_recepientID).get();

      try{
        var conversation = await _senderConversationRef?.doc(_recepientID).get();
        if(conversation?.data() != null){
          return _onSuccess(conversation!.data()?["conversationID"]);
        }else{
          var _conversationRef = _ref?.doc();
          await _conversationRef?.set({
            "members": [_currentID, _recepientID],
            "ownerID": _currentID,
            "messages": [],
          });
          await _senderConversationRef?.doc(_recepientID).set({
            "conversationID":_conversationRef?.id,
            "image": _receiverRef!.data()?["image"],
            "lastMessage": null,
            "name": _receiverRef.data()?["name"],
            "timestamp": null,
            "unseenCount":0,
          });
          await _receiverConversationRef?.doc(_currentID).set({
            "conversationID":_conversationRef?.id,
            "image": _senderRef!.data()?["image"],
            "lastMessage": null,
            "name": _senderRef.data()?["name"],
            "timestamp": null,
            "unseenCount":0,
          });
          return _onSuccess(_conversationRef!.id);
        }
      }catch(e){
        print(e);
      }
  }

  Stream<ContactModel>? getUserData(String _userID) {
    var _ref = _db?.collection(_userCollection).doc(_userID);
    
    return _ref?.get().asStream().map((_snapshot) {
      return ContactModel.fromSnapshot(_snapshot);
    });
  }

  Stream<List<ConversationSnippet>>? getUserConversations(String _userID) {
    var _ref = _db
        ?.collection(_userCollection)
        .doc(_userID)
        .collection(_conversationsCollection);
    
    return _ref?.snapshots().map((_snapshot) {
      return _snapshot.docs.map((_doc) {
        return ConversationSnippet.fromSnapshot(_doc);
      }).toList();
    });
  }

  Stream<List<ContactModel>>? getUsers(String _searchName) {
    var _ref = _db
        ?.collection(_userCollection)
        .where("name", isGreaterThanOrEqualTo: _searchName)
        .where("name", isLessThan: '${_searchName}z');
    
    return _ref?.get().asStream().map((_snapshot) {
      return _snapshot.docs.map((_doc) {
        return ContactModel.fromSnapshot(_doc);
      }).toList();
    });
  }

  Stream<Conversation>? getConversationData(String _conversationID){
    var _ref = _db?.collection(_conversationsCollection).doc(_conversationID);

    return _ref?.snapshots().map((_snapshot){
      return Conversation.fromSnapshot(_snapshot);
    });
  }
}
