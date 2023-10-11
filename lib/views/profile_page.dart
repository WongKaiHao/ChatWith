import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import './../models/contact_model.dart';

import './../services/db_service.dart';

import './../providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  final double _height;
  final double _width;

  AuthProvider? _auth;

  ProfilePage(this._height, this._width, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme
          .of(context)
          .colorScheme
          .background,
      height: _height,
      width: _width,
      child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: _profilePageUI()
      ),
    );
  }

  Widget _profilePageUI() {
    return Builder(builder: (BuildContext _context) {
      _auth = Provider.of<AuthProvider>(_context);
      return StreamBuilder<ContactModel>(
        stream: DBService.instance.getUserData(_auth!.user!.uid),
        builder: (BuildContext _context, _snapshot) {
          var _userData = _snapshot.data;
          return _snapshot.hasData ? Align(
            child: SizedBox(
              height: _height * 0.50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _userImageWidget(_userData!.image),
                  _userNameWidget(_userData.name),
                  _userEmailWidget(_userData!.email),
                  _logoutButton()
                ],
              ),
            )
          ):
          const SpinKitWanderingCubes(
            color: Colors.blue,
            size: 50.0,
          );
        }
      );
    });
  }

  Widget _userImageWidget(String _image) {
    double _imageRadius = _height * 0.20;
    return Container(
      height: _imageRadius,
      width: _imageRadius,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_imageRadius),
          image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(_image)
          )
      ),
    );
  }

  Widget _userNameWidget(String _userName) {
    return Container(
      height: _height * 0.05,
      width: _width,
      child: Text(
        _userName,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
    );
  }

  Widget _userEmailWidget(String _email) {
    return Container(
      height: _height * 0.03,
      width: _width,
      child: Text(
        _email,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      height: _height * 0.06,
      width: _width * 0.80,
      child: MaterialButton(
        onPressed: () {
          _auth?.logoutUser(() async {});
        },
        color: Colors.red,
        child: const Text(
          "LOGOUT",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}