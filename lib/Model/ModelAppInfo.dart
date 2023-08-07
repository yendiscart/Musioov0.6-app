import 'dart:convert';

class ModelAppInfo {
  bool status;
  String msg;
  List<Data> data;
  ModelAppInfo(this.status, this.msg,this.data);
  factory ModelAppInfo.fromJson(Map<dynamic, dynamic> json) {
    return ModelAppInfo(json['status'],
        json['msg'],
        List<Data>.from(json["data"].map((x) => Data.fromJson(x)))
    );
  }
}

class Data {
  int id ;
  String title = "";
  String detail = "";
  Data(this.id, this.title,this.detail);
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(json['id'],json['title'],json['detail']);
  }

}



