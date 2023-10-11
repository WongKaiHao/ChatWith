import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;

import './conversation_page.dart';

import './../services/db_service.dart';
import './../services/navigation_service.dart';

import './../providers/auth_provider.dart';

import './../models/conversation_model.dart';
import './../models/message_model.dart';

class RecentConversationsPage extends StatelessWidget {
  final double _height;
  final double _width;

  AuthProvider? _auth;

  RecentConversationsPage(this._height, this._width, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      width: _width,
      child: ChangeNotifierProvider.value(
        value:AuthProvider.instance,
        child: _conversationsListViewWidget()
      ),
    );
  }

  Widget _conversationsListViewWidget() {
    return Builder(builder: (BuildContext _context){
      _auth = Provider.of<AuthProvider>(_context);
      return Container(
        height: _height,
        width: _width,
        padding: const EdgeInsets.only(top: 10),
        child: StreamBuilder<List<ConversationSnippet>>(
          stream: DBService.instance.getUserConversations(_auth!.user!.uid),
          builder: (_context,_snapshot){
            var _data =_snapshot.data;

            if(_data != null){
              _data.removeWhere((_c) {
                return _c.timestamp == null;
              });

              return _data.length>0 ? ListView.builder(
                itemCount: _data.length,
                itemBuilder: (_context, _index) {
                  return ListTile(
                    onTap: (){
                      // Update unseenCount to 0
                      DBService.instance.resetUnseenCount(_auth!.user!.uid, _data[_index].id);

                      // Navigate to Conversation Page
                      NavigationService.instance.navigateToRoute(MaterialPageRoute(builder: (BuildContext _context){
                        return ConversationPage(conversationID:_data[_index].conversationID, receiverID:_data[_index].id, receiverImg:_data[_index].image, receiverName:_data[_index].name);
                      }));
                    },
                    title: Text(_data[_index].name),
                    subtitle: Text(
                        _data[_index].type == MessageType.Text
                        ? _data[_index].lastMessage.characters.length>46 ? _data[_index].lastMessage.substring(0,43)+"...":_data[_index].lastMessage
                        : "[Image]"),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(_data[_index].image)
                        )
                      ),
                    ),
                      trailing: _listTileTrailingWidget(_data[_index].timestamp!, _data[_index].unseenCount, _data[_index].lastMessage.toString())
                  );
                }):
              const Align(
                child: Text(
                  "You have no conversations yet!",
                  style: TextStyle(color: Colors.white30, fontSize: 20.0,),
                  textAlign: TextAlign.center,
                ),
              );
            }else{
              return const SpinKitWanderingCubes(
                color: Colors.blue,
                size: 50.0,
              );
            }
        })
      );
    });
  }

  Widget _listTileTrailingWidget(Timestamp _lastMessageTimestamp, int _unseenCount, String _message){
    // var _timeDifference = _lastMessageTimestamp.toDate().difference(DateTime.now());
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(timeago.format(_lastMessageTimestamp.toDate()),style: const TextStyle(fontSize: 15),),
        _unseenCount>0?
          Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
              color:  Colors.green,
              borderRadius: BorderRadius.circular(100)
          ),
          child: Center(child: Text(_unseenCount.toString(),style: const TextStyle(fontSize: 10,fontWeight: FontWeight.w900),)),
        ):
        SizedBox(
          height: _message.length >24 ?30:5,
        )
      ],
    );
  }
}