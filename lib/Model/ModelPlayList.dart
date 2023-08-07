import 'dart:convert';

import 'ModelMusicList.dart';



class ModelPlayList {
  bool status;
  String msg;

  List<DataCat> data;


  ModelPlayList(this.status, this.msg,this.data);

  factory ModelPlayList.fromJson(Map<String, dynamic> json) {


    List<DataCat> d=   List<DataCat>.from(json["data"].map((x) => DataCat.fromJson(x)));



    return ModelPlayList(json['status'],
        json['msg'],

      d
    );
  }
}

class DataCat {

  int id ;
  int user_id;
  String playlist_name = "";

  List<DataMusic> song_list;
  String created_at = "";
  String updated_at = "";


  DataCat(this.id,this.user_id, this.playlist_name, this.song_list, this.created_at,this.updated_at);
  factory DataCat.fromJson(Map<String, dynamic> json) {


    List<DataMusic> d=   List<DataMusic>.from(json["song_list"].map((x) => DataMusic.fromJson(x)));

    return DataCat(json['id'],json['user_id'],json['playlist_name'], d,json['created_at']
        ,json['updated_at']);
  }

}
class SubData {
  int id;

  String image = "";
  String audio = "";
  String audio_duration = "";
  String audio_title = "";
  String audio_slug = "";
  int audio_genre_id;

  String artist_id = "";
  String artists_name = "";
  String audio_language = "";
  int listening_count;
  int is_featured;

  int is_trending;
  int is_recommended;
  String created_at = "";

  SubData(this.id, this.image, this.audio, this.audio_duration,
      this.audio_title, this.audio_slug, this.audio_genre_id, this.artist_id,
      this.artists_name, this.audio_language, this.listening_count
      , this.is_featured
      , this.is_trending, this.created_at, this.is_recommended);

  factory SubData.fromJson(Map<String, dynamic> json) {
    return SubData(
        json['id'],
        json['image'],
        json['audio'],
        json['audio_duration'],
        json['audio_title'],
        json['audio_slug'],
        json['audio_genre_id'],
        json['artist_id'],
        json['artists_name'],
        json['audio_language']
        ,
        json['listening_count'],
        json['is_featured'],
        json['is_trending'],
        json['created_at'],
        json['is_recommended']);
  }
}






