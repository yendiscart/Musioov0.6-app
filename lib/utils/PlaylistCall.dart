import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:musioo/Model/ModelPlayListYT.dart';

class PlaylistCall {

  late Dio _dio = Dio();
 Future<ModelPlayListYT> getPlaylist(String playlistId,String keyAPI) async {

    Response<String> response = await _dio.get("https://www.googleapis.com/youtube/v3/playlistItems"
        "?part=snippet&playlistId="+playlistId+"&key="+keyAPI+"&maxResults=50",

        options: Options(headers: {
          "contentType": "application/json",
        }));


    if (response.statusCode == 200) {
      final Map<String, dynamic> parsed = json.decode(response.data.toString());

   return  ModelPlayListYT.fromJson(parsed);
    }else{
 final Map<String, dynamic> parsed = json.decode(response.data.toString());
    return  ModelPlayListYT.fromJson(parsed);
    }
  }
}