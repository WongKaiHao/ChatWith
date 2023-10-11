import 'package:cloud_firestore/cloud_firestore.dart';

import './message_model.dart';

class ConversationSnippet{
  final String id;
  final String conversationID;
  final String lastMessage;
  final String name;
  final String image;
  final MessageType type;
  final int unseenCount;
  final Timestamp? timestamp;

  ConversationSnippet(
    {
      required this.id,
      required this.conversationID,
      required this.lastMessage,
      required this.name,
      required this.image,
      required this.type,
      required this.unseenCount,
      required this.timestamp
    });

  factory ConversationSnippet.fromSnapshot(DocumentSnapshot _snapshot){
    final Map<String, dynamic>? _data = _snapshot.data() as Map<String, dynamic>?;
    var _messageType = MessageType.Text;

    if(_data?["type"] != null){
      switch(_data?["type"]) {
        case "text":
          break;
        case "image":
          _messageType = MessageType.Image;
          break;
      }
    }

    return ConversationSnippet(
      id: _snapshot.id,
      conversationID: _data?["conversationID"],
      lastMessage: _data?["lastMessage"] ?? "",
      name: _data?["name"],
      image: _data?["image"],
      type: _messageType,
      unseenCount: _data?["unseenCount"],
      timestamp: _data?["timestamp"] != null
          ? (_data?["timestamp"])
          : null,
    );
  }
}

class Conversation {
  final String id;
  final List members;
  final List<Message> messages;
  final String ownerID;

  Conversation({required this.id, required this.members, required this.messages, required this.ownerID});

  factory Conversation.fromSnapshot(DocumentSnapshot _snapshot){
    Map<String, dynamic>? _data = _snapshot.data() as Map<String, dynamic>?;
    List? _messages = _data?["messages"];

    if(_messages != null ){
      _messages = _messages.map((_message){
        return Message(
          senderID: _message["senderID"],
          content: _message["message"],
          timestamp: _message["timestamp"],
          type: _message["type"] == "text" ? MessageType.Text : MessageType.Image
        );
      }).toList();
    }else {
      _messages = [];
    }

    return Conversation(
      id: _snapshot.id,
      members: List.from(_data?["members"]),
      messages: _messages.cast<Message>(),
      ownerID: _data?["ownerID"]
    );
  }
}