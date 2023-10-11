import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './../services/snackbar_service.dart';
import './../services/navigation_service.dart';
import './../services/db_service.dart';

enum AuthStatus{
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error,
}

class AuthProvider extends ChangeNotifier{
  User? user;
  late FirebaseAuth _auth;
  AuthStatus? status;

  static AuthProvider instance = AuthProvider();

  AuthProvider(){
    _auth = FirebaseAuth.instance;
    _checkCurrentUserIsAuthenticated();
  }

  void _autologin() async{
    if(user != null){
      await DBService.instance.updateUserLastSeenTime(user!.uid);
      return NavigationService.instance.navigateToReplacement("home");
    }
  }

  void _checkCurrentUserIsAuthenticated() async {
    user = _auth.currentUser!;
    if(user != null){
      notifyListeners();
      _autologin();
    }
  }

  Future<bool> resetPassword(String _email) async {
    try{
      await _auth.sendPasswordResetEmail(email: _email.trim());
      return true;
    }catch (e){
      print(e);
      return false;
    }
  }

  void loginUserWithEmailAndPassword(String _email, String _password) async{
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.signInWithEmailAndPassword(email: _email, password: _password);
      user = _result.user!;
      status = AuthStatus.Authenticated;

      SnackbarService.instance.showSnackBarSuccess("Welcome, ${user?.email}");

      //Update LastSeen Time
      await DBService.instance.updateUserLastSeenTime(user!.uid);

      //Navigate to Homepage
      NavigationService.instance.navigateToReplacement("home");

    } catch (e){
      status = AuthStatus.Error;
      user=null;
      //Display error
      SnackbarService.instance.showSnackBarError("Authentication Error");
    }
    notifyListeners();
  }

  void registerUserWithEmailAndPassword(String _email, String _password,
    Future<void> onSuccess(String _uid)) async{
      status = AuthStatus.Authenticating;
      notifyListeners();
      try{
        UserCredential _result = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
        user = _result.user!;
        status = AuthStatus.Authenticated;
        await onSuccess(user!.uid);

        SnackbarService.instance.showSnackBarSuccess("Welcome, ${user?.email}");

        //Update LastSeen Time
        await DBService.instance.updateUserLastSeenTime(user!.uid);

        NavigationService.instance.goBack();
        //Navigate To HomePage
        NavigationService.instance.navigateToReplacement("home");
      }catch(e){
        status = AuthStatus.Error;
        user = null;
        //Display error
        SnackbarService.instance.showSnackBarError("Registration Error");
      }
    }

    void logoutUser(Future<void> onSuccess()) async{
      try{
        await _auth.signOut();
        user = null;
        status = AuthStatus.NotAuthenticated;
        await onSuccess();
        await NavigationService.instance.navigateToReplacement("login");
        SnackbarService.instance.showSnackBarSuccess("Logged out Successfully");
      }catch(e){
        SnackbarService.instance.showSnackBarError("Error Logging out");
      }
      notifyListeners();
    }
}