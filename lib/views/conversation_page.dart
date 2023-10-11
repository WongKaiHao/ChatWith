import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

import './../providers/auth_provider.dart';

import './../models/conversation_model.dart';
import './../models/message_model.dart';

import './../services/db_service.dart';
import './../services/media_service.dart';
import './../services/cloud_storage_service.dart';

class ConversationPage extends StatefulWidget{
  late String _conversationID;
  late String _receiverID;
  late String _receiverImg;
  late String _receiverName;

  ConversationPage({super.key, required String conversationID, required String receiverID, required String receiverImg, required String receiverName}){
    _conversationID = conversationID;
    _receiverID = receiverID;
    _receiverImg = receiverImg;
    _receiverName = receiverName;
  }

  @override
  State<StatefulWidget> createState() {
    return _ConversationPageState();
  }
}

class _ConversationPageState extends State<ConversationPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late GlobalKey<FormState> _formKey;
  late ScrollController _listViewController;
  AuthProvider? _auth;

  late String _messageText;

  _ConversationPageState(){
    _formKey = GlobalKey<FormState>();
    _listViewController = ScrollController();
    _messageText = "";
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(31, 31, 31, 1.0),
        title: Text(widget._receiverName),
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationPageUI()
      ),
    );
  }

  Widget _conversationPageUI(){
    return Builder(
      builder: (BuildContext _context){
        _auth = Provider.of<AuthProvider>(_context);
        return Stack(
          clipBehavior:Clip.none,
          children: <Widget>[
            _messageListView(),
            Align(
              alignment: Alignment.bottomCenter,
              child: _messageField(_context),
            )
          ],
        );
    });
  }

  Widget _messageListView(){
    return SizedBox(
      height: _deviceHeight * 0.75,
      width: _deviceWidth,
      child: StreamBuilder<Conversation>(
        stream: DBService.instance.getConversationData(widget._conversationID),
        builder: (BuildContext _context, _snapshot) {
          var _conversationData = _snapshot.data;

          if(_conversationData != null){
            if(_conversationData.messages.isNotEmpty){
              Timer(const Duration(milliseconds: 50), () => _listViewController.jumpTo(_listViewController.position.maxScrollExtent)
              );
              return ListView.builder(
                  controller: _listViewController,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  itemCount: _conversationData.messages.length,
                  itemBuilder: (BuildContext _context, int _index){
                    var _message = _conversationData.messages[_index];
                    bool _isOwnMessage = _message.senderID == _auth?.user?.uid;
                    return _messageListViewChild(_isOwnMessage, _message);
                  });
            }else{
              return const Align(
                alignment: Alignment.center,
                child: Text("Let's start a conversation"),
              );
            }
          }else{
            return const SpinKitWanderingCubes(
              color: Colors.blue,
              size: 50.0,
            );
          }
        }),
    );
  }

  Widget _messageListViewChild(bool _isOwnMessage, Message _message){
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: _isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          !_isOwnMessage ? _userImageWidget() : Container(),
          SizedBox(width: _deviceWidth * 0.02,),
          _message.type == MessageType.Text
            ? _textMessageBubble(_isOwnMessage, _message.content, _message.timestamp)
            : _imageMessageBubble(_isOwnMessage, _message.content, _message.timestamp),
        ],
      ),
    );
  }

  Widget _userImageWidget(){
    double _imgRadius = _deviceHeight * 0.05;
    return Container(
      height: _imgRadius,
      width: _imgRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(widget._receiverImg!)
        )
      ),
    );
  }

  Widget _textMessageBubble(bool _isOwnMessage, String _message, Timestamp _timestamp){
    List<Color> _colorScheme = _isOwnMessage
        ? [Colors.blue, const Color.fromRGBO(42, 117, 188, 1.0)]
        : [const Color.fromRGBO(69, 69, 69, 1.0), const Color.fromRGBO(43, 43, 43, 1.0)];
    return Container(
      height: _deviceHeight * 0.08 + (_message.length / 20 * 5.0),
      width: _deviceWidth * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: _isOwnMessage
        ? const BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
          bottomLeft: Radius.circular(15.0),
        ) : const BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
        ),
        gradient: LinearGradient(
          colors: _colorScheme,
          stops: const [0.30,0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(_message),
          Text(timeago.format(_timestamp.toDate()), style: TextStyle(color: Colors.white70),)
        ],
      ),
    );
  }

  Widget _imageMessageBubble(bool _isOwnMessage, String _imgUrl, Timestamp _timestamp){
    List<Color> _colorScheme = _isOwnMessage
        ? [Colors.blue, const Color.fromRGBO(42, 117, 188, 1.0)]
        : [const Color.fromRGBO(69, 69, 69, 1.0), const Color.fromRGBO(43, 43, 43, 1.0)];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: _isOwnMessage
          ? const BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
            bottomLeft: Radius.circular(15.0),
          ) : const BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),
          gradient: LinearGradient(
              colors: _colorScheme,
              stops: const [0.30,0.70],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight
          )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: _deviceHeight * 0.30,
            width: _deviceWidth * 0.40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(image: NetworkImage(_imgUrl), fit: BoxFit.cover)
            ),
          ),
          Text(timeago.format(_timestamp.toDate()), style: const TextStyle(color: Colors.white70),)
        ],
      ),
    );
  }

  Widget _messageField(BuildContext _context){
    return Container(
      height: _deviceHeight * 0.08,
      decoration: BoxDecoration(
        color: Color.fromRGBO(43, 43, 43, 1.0),
        borderRadius: BorderRadius.circular(100)
      ),
      margin: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.04, vertical: _deviceHeight * 0.03),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _messageTextField(),
            _sendMessageButton(_context),
            _imageMessageButton()
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.55,
      child: TextFormField(
        onChanged: (_input){
          _formKey.currentState?.save();
        },
        onSaved: (_input){
          _messageText = _input!;
        },
        cursorColor: Colors.white,
        decoration: const InputDecoration(border: InputBorder.none, hintText: "Type a message"),
        autocorrect: false,
      ),
    );
  }

  Widget _sendMessageButton(BuildContext _context){
    return SizedBox(
      height: _deviceHeight * 0.05,
      width: _deviceWidth * 0.05,
      child: IconButton(
        icon: const Icon(Icons.send,color: Colors.white,),
        onPressed: (){
          if(_messageText.isNotEmpty){
            DBService.instance.sendMessage(
              widget._conversationID,
              Message(
                senderID: _auth!.user!.uid,
                content: _messageText,
                timestamp: Timestamp.now(),
                type: MessageType.Text
              )
            );
            DBService.instance.updateLastseenCount(
              _auth!.user!.uid,
              widget._receiverID
            );
            DBService.instance.updateBothInfo(
                _auth!.user!.uid,
                widget._receiverID,
                _messageText,
                MessageType.Text
            );
            _formKey.currentState?.reset();
            setState(() {
              _messageText="";
            });
            FocusScope.of(_context).unfocus();
          }
        },
      ),
    );
  }

  Widget _imageMessageButton(){
    return SizedBox(
      height: _deviceHeight * 0.10,
      width: _deviceWidth * 0.10,
      child: FloatingActionButton(
        onPressed: () async {
          XFile? _image = await MediaService.instance.getImageFromLibrary();

          if(_image != null){
            var _result = await CloudStorageService.instance.uploadMediaMessage(_auth!.user!.uid, File(_image.path));
            var _imgUrl = await _result?.ref.getDownloadURL();
            await DBService.instance.sendMessage(widget._conversationID,
              Message(
                senderID: _auth!.user!.uid,
                content: _imgUrl!,
                timestamp: Timestamp.now(),
                type: MessageType.Image
              )
            );
            DBService.instance.updateLastseenCount(
                _auth!.user!.uid,
                widget._receiverID,
            );
            DBService.instance.updateBothInfo(
                _auth!.user!.uid,
                widget._receiverID,
                _imgUrl,
                MessageType.Image
            );
          }
        },
        child: const Icon(Icons.camera_enhance,),
      ),
    );
  }
}