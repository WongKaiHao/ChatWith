import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import './../providers/auth_provider.dart';

import './../services/snackbar_service.dart';
import './../services/keyboard_service.dart';
import './../services/navigation_service.dart';
import './../services/media_service.dart';
import './../services/cloud_storage_service.dart';
import './../services/db_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegistrationPageState();
  }
}

class _RegistrationPageState extends State<RegistrationPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late GlobalKey<FormState> _formKey;
  AuthProvider? _auth;

  File? _image;
  String? _name;
  String? _email;
  String? _password;

  _RegistrationPageState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        alignment: Alignment.center,
        child: ChangeNotifierProvider<AuthProvider>.value(
            value: AuthProvider.instance, child: registrationPageUI()),
      ),
    );
  }

  Widget registrationPageUI() {
    return Builder(builder: (BuildContext _context) {
      SnackbarService.instance.buildContext = _context;
      _auth = Provider.of<AuthProvider>(_context);
      return SingleChildScrollView(
        child: Container(
          height: _deviceHeight * 0.80,
          padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _headingWidth(),
              _inputForm(),
              _registerButton(),
              const SizedBox(height: 4,),
              _backToLoginPageButton()
            ],
          ),
        ),
      );
    });
  }

  Widget _headingWidth() {
    return SizedBox(
      height: _deviceHeight * 0.12,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Let's get going!",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
          Text(
            "Please enter your details.",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
          )
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      margin: EdgeInsets.only(bottom: _deviceHeight * 0.03),
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState?.save();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _imageSelectorWidget(),
            _nameTextField(),
            const SizedBox(height: 4,),
            _emailTextField(),
            const SizedBox(height: 4,),
            _passwordTextField(),
            const SizedBox(height: 4,),
            _confirmPasswordTextField()
          ],
        ),
      ),
    );
  }

  Widget _imageSelectorWidget() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () async {
          selectImage();
        },
        child: Container(
          height: _deviceHeight * 0.15,
          width: _deviceWidth * 0.30,
          decoration: BoxDecoration(
            color: _image != null ? Colors.transparent : Colors.white,
            borderRadius: BorderRadius.circular(500),
          ),
          child: ClipOval(
            child: (_image != null)
                ? Image(
                    fit: BoxFit.cover,
                    image: FileImage(_image!),
                  )
                : const Icon(
                    Icons.add_photo_alternate,
                    size: 75,
                    color: Colors.grey,
                  ),
          ),
        ),
      ),
    );
  }

  Future selectImage(){
    return showDialog(
      context: context,
      builder: (BuildContext _context) {
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
        ),
        child: SizedBox(
          height: _deviceHeight * 0.25,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                const Text(
                  'Select Image From ',
                  style: TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: _deviceHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        XFile? _imageFile = await MediaService.instance.getImageFromLibrary();
                        setState(() {
                          _image = File(_imageFile!.path);
                        });
                        NavigationService.instance.goBack();
                      },
                      child: const Card(
                        color: Colors.white30,
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.photo_library,
                                size: 50,
                              ),
                              SizedBox(height: 10),
                              Text('Gallery', style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                            ],
                          ),
                        )
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        XFile? _imageFile = await MediaService.instance.getImageFromCamera();
                        setState(() {
                          _image = File(_imageFile!.path);
                        });
                        NavigationService.instance.goBack();
                      },
                      child: const Card(
                        color: Colors.white30,
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.camera_enhance,
                                size: 50,
                              ),
                              SizedBox(height: 10),
                              Text('Camera', style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                            ],
                          ),
                        )
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _nameTextField() {
    return TextFormField(
      autocorrect: false,
      style: const TextStyle(color: Colors.white),
      validator: (_input) {
        return _input!.isNotEmpty ? null : "Please enter your name";
      },
      onSaved: (_input) {
        setState(() {
          _name = _input;
        });
      },
      cursorColor: Colors.white,
      decoration: const InputDecoration(
          hintText: "Name",
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white))),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      autocorrect: false,
      style: const TextStyle(color: Colors.white),
      validator: (_input) {
        return _input!.isNotEmpty && _input.contains("@")
            ? null
            : "Please enter a valid email";
      },
      onSaved: (_input) {
        setState(() {
          _email = _input;
        });
      },
      cursorColor: Colors.white,
      decoration: const InputDecoration(
          hintText: "Email Address",
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white))),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      style: TextStyle(color: Colors.white),
      validator: (_input) {
        return (_input?.length != 0 && _input!.length < 8)
            ? null
            : "Please enter at least 8 character password";
      },
      onSaved: (_input) {
        setState(() {
          _password = _input;
        });
      },
      cursorColor: Colors.white,
      decoration: const InputDecoration(
          hintText: "Password",
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white))),
    );
  }

  Widget _confirmPasswordTextField() {
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      style: TextStyle(color: Colors.white),
      validator: (_input) {
        return (_input?.length == 0 || _input != _password)
            ? "Password not matched"
            : null;
      },
      onSaved: (_input) {},
      cursorColor: Colors.white,
      decoration: const InputDecoration(
          hintText: "Confirm Password",
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white))),
    );
  }

  Widget _registerButton() {
    return _auth?.status == AuthStatus.Authenticating
        ? const Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          )
        : SizedBox(
            height: _deviceHeight * 0.06,
            width: _deviceWidth,
            child: MaterialButton(
              onPressed: () {
                KeyboardService.instance.hideKeyboard(context);
                if (_image == null) {
                  SnackbarService.instance
                      .showSnackBarInfo("Please select a image");
                }

                if (_formKey.currentState!.validate() && _image != null) {
                  _auth?.registerUserWithEmailAndPassword(_email!, _password!,
                      (String _uid) async {
                    var _result = await CloudStorageService.instance
                        .uploadUserImage(_uid, _image!);
                    var _imageUrl = await _result?.ref.getDownloadURL();
                    await DBService.instance
                        .createUser(_uid, _name!, _email!, _imageUrl!);
                  });
                }
              },
              color: Colors.blue,
              child: const Text(
                "REGISTER",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
  }

  Widget _backToLoginPageButton() {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.goBack();
      },
      child: SizedBox(
        height: _deviceHeight * 0.06,
        width: _deviceWidth,
        child: const Icon(
          Icons.arrow_back,
          size: 40,
        ),
      ),
    );
  }
}
