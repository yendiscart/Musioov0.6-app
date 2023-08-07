import 'dart:convert';
List<DataMusic> d=[];
class ModelMusicList {
  bool status;
  String msg;
  String imagePath;
  String audioPath;
  List<DataMusic> data;


  ModelMusicList(this.status, this.msg,this.data,this.imagePath,this.audioPath);

  factory ModelMusicList.fromJson(Map<String, dynamic> json) {
    if(List<DataMusic>.from(json["data"].map((x) => DataMusic.fromJson(x))).length > 0){
     d=   List<DataMusic>.from(json["data"].map((x) => DataMusic.fromJson(x)));}else{
   d=[];
    }



    return ModelMusicList(json['status'],
        json['msg'],
      d,
      json['imagePath'],
      json['audioPath']
    );
  }
}

class DataMusic {

  int id ;
  String image = "";
  String audio = "";
  String audio_duration = "";
  String audio_title = "";
  String audio_slug = "";
  int audio_genre_id ;
  String artist_id = "";
  String artists_name = "";
  String audio_language = "";
  int listening_count;
  int is_featured ;
  int is_trending;
  int is_recommended;
  String created_at = "";
  String favourite = "";
  String download_price = "";

  DataMusic(this.id,this.image, this.audio, this.audio_duration, this.audio_title, this.audio_slug, this.audio_genre_id,
      this.artist_id,this.artists_name, this.audio_language, this.listening_count
      , this.is_featured
      , this.is_trending,this.created_at,this.is_recommended,this.favourite,this.download_price);

  factory DataMusic.fromJson(Map<String, dynamic> json) {




    return DataMusic(json['id'],json['image'],json['audio'],json['audio_duration'],json['audio_title'],json['audio_slug'],json['audio_genre_id'],
        json['artist_id'],  json['artists_name'],json['audio_language']
        ,json['listening_count'],json['is_featured'],json['is_trending'],json['created_at'],json['is_recommended'],json['favourite'],json['download_price'] ?? '');
  }

}
















