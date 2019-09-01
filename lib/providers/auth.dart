import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/helpers/secret_loader.dart';
import 'package:my_shop/models/http_exception.dart';
import 'package:my_shop/models/secret.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  String _userId;
  DateTime _expireDate;
  Timer _authTimer;
  String _apiKey;

  Auth(){
    Future<Secret> secret = SecretLoader(secretPath: "assets/secrets.json").load();
    secret.then((s)=> this._apiKey = s.apiKey);
  }
  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expireDate != null &&
        _expireDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    } else {
      return null;
    }
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String apiUrl) async {
    try {
      final response = await http.post(
        apiUrl,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expireDate = DateTime.now().add(
        Duration(seconds: int.parse(responseData['expiresIn'])),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expireDate': _expireDate.toIso8601String(),
      });

      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${_apiKey}';
    return _authenticate(email, password, url);
  }

  Future<void> signIn(String email, String password) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${_apiKey}';
    return _authenticate(email, password, url);
  }

  Future<bool> tryAutoLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expireDate = DateTime.parse(extractedUserData['expireDate']);
    if (expireDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expireDate = expireDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logOut() async {
    _token = null;
    _expireDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final prefs =  await SharedPreferences.getInstance();
    prefs.remove('userData');
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    _authTimer = Timer(
        Duration(
          seconds: _expireDate
              .difference(
                DateTime.now(),
              )
              .inSeconds,
        ),
        logOut);
  }
}
