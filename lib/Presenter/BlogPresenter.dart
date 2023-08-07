


import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:musioo/Model/BlogModel.dart';
import 'package:musioo/utils/AppConstant.dart';



class BlogPresenter{
  late Dio _dio = Dio();


  Future<String> getBlog(String token) async {

    Response<String> response = await _dio.get(AppConstant.BaseUrl+AppConstant.API_Blog, options: Options(headers: {
      "Accept": "application/json",
      "authorization": "Bearer " + token
    }));

      if (response.statusCode == 200) {

        return response.data.toString();
      } else {


        return '';
      }

  }
}

