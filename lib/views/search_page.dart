import 'package:chatwith/services/navigation_service.dart';
import 'package:chatwith/views/conversation_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;

import './../services/db_service.dart';

import './../providers/auth_provider.dart';

import './../models/contact_model.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  AuthProvider? _auth;

  String? _searchText;
  final TextEditingController _searchController = TextEditingController();

  _SearchPageState() {
    _searchText = "";
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: _userSearchField(),
        actions: [if(_searchText!.isNotEmpty)
          IconButton(
            onPressed: (){
              setState(() {
                _searchController.clear();
                _searchText = "";
              });
            },
            icon: const Icon(Icons.clear)
          )
        ],
        backgroundColor: Theme.of(context).colorScheme.background,
        titleSpacing: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ChangeNotifierProvider.value(
        value: AuthProvider.instance,
        child: _searchPageUI()
      ),
    );
  }

  Widget _searchPageUI() {
    return Builder(builder: (BuildContext _context) {
      _auth = Provider.of<AuthProvider>(_context);
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: _deviceHeight * 0.01,),
            _userListView()],
        ),
      );
    });
  }

  Widget _userSearchField() {
    return SizedBox(
        height: _deviceHeight * 0.08,
        width: _deviceWidth,
        child: Align(
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: _searchController,
            autocorrect: false,
            style: const TextStyle(color: Colors.white),
            onChanged: (_input) {
              setState(() {
                _searchText = _input;
              });
            },
            decoration: const InputDecoration(
              hintText: "Search",
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
          ),
        ),
      );
  }

  Widget _userListView() {
    return StreamBuilder<List<ContactModel>>(
      stream: DBService.instance.getUsers(_searchText!),
      builder: (_context, _snapshot) {
        var _usersData = _snapshot.data;
        if(_usersData != null) {
          _usersData.removeWhere((_contact) =>
          _contact.id == _auth?.user?.uid);
        }

        return _snapshot.hasData
          ? SizedBox(
            height: _deviceHeight,
            child: ListView.builder(
              itemCount:  _usersData?.length ?? 0,
              itemBuilder: (BuildContext _context, int _index) {
                var _userData = _usersData?[_index];
                var _currentTime = DateTime.now();
                var _recepientID = _usersData?[_index].id;
                var _isUserActive = !_userData!.lastSeen.toDate().isBefore(_currentTime.subtract(const Duration(days: 1)));

                return ListTile(
                  onTap: (){
                    DBService.instance.createOrGetConversation(_auth!.user!.uid, _recepientID!, (String _conversationID) async {
                      NavigationService.instance.backAndNavigateTo(MaterialPageRoute(builder: (_context){
                        return ConversationPage(conversationID:_conversationID, receiverID:_recepientID, receiverImg:_userData.image, receiverName:_userData.name);
                      }));
                    });
                  },
                  title: Text(_userData.name),
                  subtitle: !_isUserActive
                      ? Text("Last active : ${_userData.lastSeen.toDate().day}/${_userData.lastSeen.toDate().month}/${_userData.lastSeen.toDate().year}")
                      : Text("Last active : ${timeago.format(_userData.lastSeen.toDate())}"),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(_userData.image)
                      )
                    ),
                  ),
                );
              }
            )
          ):
        const SpinKitWanderingCubes(
          color: Colors.blue,
          size: 50.0,
        );
        }
      );
  }
}
