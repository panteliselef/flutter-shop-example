import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(width: double.infinity, child: Text("MyShop",textAlign: TextAlign.center,style: TextStyle(
            fontFamily: 'Anton',
            fontSize: 50,
            letterSpacing: 1,
            color: Colors.white
          ),)),
          SizedBox(height: 20,),
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),)
        ],
      ),
    );
  }
}
