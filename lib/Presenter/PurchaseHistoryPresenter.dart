import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:musioo/utils/AppConstant.dart';



class PurchaseHistoryPresenter {
  late Dio _dio = Dio();



  Future<String> purchaseHistoryInfo(
     String token) async {

    Response<String> response ;

 response = await _dio.get(
      AppConstant.BaseUrl + AppConstant.API_USER_PURCHASE_HISTORY,
      options: Options(headers: {
        "Accept": "application/json",
        "authorization": "Bearer " + token
      }));


    try {
      if (response.statusCode == 200) {
        return response.data.toString();
      } else {


        return "";
      }
    } catch (error, stacktrace) {


      return "";
    }
  }








}


