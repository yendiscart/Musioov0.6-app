import 'dart:convert';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {


  setUserData(String jsonString) async {

    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    sharedPref.setString('user', jsonString); //storing
    }
  setSettingsData(String jsonString) async {

    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    sharedPref.setString('settings', jsonString); //storing

  }

  Future<String?> getSettings() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String? settings = sharedPref.getString('settings');
    return settings;
  }

  setToken(String token) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    sharedPref.setString('token', token); //storing
  }

  Future<dynamic> getToken() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String? token = sharedPref.getString('token');
    
    return token!.replaceAll('Bearer ', '');
  }

  setThemeData(String m) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    sharedPref.setString('theme',m ); //storing
  }

  Future<dynamic> getThemeData() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    if(sharedPref.containsKey('theme')){
    String? user = sharedPref.getString('theme');
    Map decodeOptions = jsonDecode(user!);
    return ModelTheme.fromJson(decodeOptions);}else{

    }
  }

  Future<dynamic> getUserData() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String? user = sharedPref.getString('user');
    Map decodeOptions = jsonDecode(user!);
    return UserModel.fromJson(decodeOptions);
  }

  Future<bool> check() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('user')){
      return true;
    }else{
      return false;
    }
  }

  removeValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("settings");
 prefs.remove("user");
    prefs.remove("token");
    prefs.remove("settings");
    prefs.remove("boolValue");
    prefs.remove("intValue");
    prefs.remove("doubleValue");
  }
}
