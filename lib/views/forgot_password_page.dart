import 'package:flutter/material.dart';

import './../providers/auth_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ForgotPasswordPageState();
  }
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late GlobalKey<FormState> _formKey;

  late String _email;

  _ForgotPasswordPageState(){
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Forgot Password"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _forgotPasswordPageUI()
    );
  }

  Widget _forgotPasswordPageUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _headingText(),
        const SizedBox(height: 10,),
        _inputForm(),
        const SizedBox(height: 30,),
        _resetPasswordButton()
      ],
    );
  }

  Widget _headingText(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.10),
      child: const Text(
        "Enter your Email and we will send a password reset link",
        style: TextStyle(fontSize: 25),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _inputForm() {
    return Container(
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
            _emailTextField(),
          ],
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.15),
      child: TextFormField(
        autocorrect: false,
        style: const TextStyle(color: Colors.white),
        validator: (_input) {
          return _input!.isNotEmpty && _input!.contains("@")
              ? null
              : "Please enter your email address";
        },
        onSaved: (_input) {
          setState(() {
            _email = _input!;
          });
        },
        cursorColor: Colors.white,
        decoration: const InputDecoration(
            hintText: "Email Address",
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white))),
      ),
    );
  }

  Widget _resetPasswordButton(){
    return SizedBox(
      height: _deviceHeight * 0.06,
      width: _deviceWidth * 0.5,
      child: MaterialButton(
        onPressed: () async {
          bool isEmailSent= await AuthProvider.instance.resetPassword(_email);
          showInfo(isEmailSent);
        },
        color: Colors.blue,
        child: const Text(
          "Reset Password",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> showInfo(bool isEmailSent) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: isEmailSent
              ? Text("Password reset link sent! Check your email.")
              : Text("Error in sending password reset link"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}