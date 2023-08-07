import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/AppConstant.dart';



class PlanPresenter {
  late Dio _dio = Dio();


  Future<String> getAllPlans(String token) async {
    Response<String> response = await _dio.get(
        AppConstant.BaseUrl + AppConstant.API_PLAN_LIST,
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));



    try {
      if (response.statusCode == 200) {
        return response.data.toString();
      } else {
        return response.data.toString();
      }
    } catch (error, stacktrace) {


      return throw UnimplementedError();
    }
  }


  Future<String> getAllCoupons(String token) async {
    Response<String> response = await _dio.get(
        AppConstant.BaseUrl + AppConstant.API_GET_COUPON_LIST,
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));


    try {
      if (response.statusCode == 200) {
        return response.data.toString();
      } else {
        return response.data.toString();
      }
    } catch (error, stacktrace) {


      return throw UnimplementedError();
    }
  }


  Future<String> addPlanCoupon(String coupon_code,String token) async {

    print('token  '+token);
    var formData ;
    formData = FormData.fromMap({

      AppConstant.coupon_code:coupon_code,
    });

    Response<String> response = await _dio.post(
        AppConstant.BaseUrl + AppConstant.API_USER_COUPON_CODE,data: formData,

        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));


    try {
      if (response.statusCode == 200) {


        final Map<String,dynamic> parsed = json.decode(response.data.toString());

if(parsed['status'].toString().contains('false')){
          Fluttertoast.showToast(
              msg: parsed['msg'],
              toastLength:
              Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              backgroundColor:
              Colors.grey,
              textColor: appColors().colorBackground,
              fontSize: 14.0);}

return response.data.toString();

      }
      return response.data.toString();

    } catch (error, stacktrace) {
      return '';
    }
  }

  Future<String> savePlan(String type,String plan_id,String payment_data,String order_id,String token) async {


    var formData ;
    formData = FormData.fromMap({

      AppConstant.type:type,
      AppConstant.plan_id:plan_id,
      AppConstant.payment_data:payment_data,
      AppConstant.order_id:order_id,
    });

    Response<String> response = await _dio.post(
        AppConstant.BaseUrl + AppConstant.API_SAVE_PAYMENT_TRANSACTION,data: formData,

        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));

    try {
      if (response.statusCode == 200) {

        final Map<String,dynamic> parsed = json.decode(response.data.toString());


        Fluttertoast.showToast(
            msg: parsed['msg'],
            toastLength:
            Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            backgroundColor:
            Colors.grey,
            textColor: appColors().colorBackground,
            fontSize: 14.0);

        return response.data.toString();

      }
      return response.data.toString();

    } catch (error, stacktrace) {
      return '';
    }
  }




  Future<String> singleSongPay(String payment_gateway,String id,String payment_data,String token) async {

print(" data--  "+payment_gateway+"  , "+payment_data+"   "+id+"   ,  "+token);
    var formData ;
    formData = FormData.fromMap({
      "audio_id":id,
      "payment_gateway":payment_gateway,
      "payment_data":payment_data,
      "status":1,
    });



    try {

      Response<String> response = await _dio.post(
          AppConstant.BaseUrl + AppConstant.API_buy_audio_to_download,data: formData,

          options: Options(headers: {
            "Accept": "application/json",
            "authorization": "Bearer " + token
          }));

      if (response.statusCode == 200) {

        final Map<String,dynamic> parsed = json.decode(response.data.toString());


        Fluttertoast.showToast(
            msg: parsed['msg'],
            toastLength:
            Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            backgroundColor:
            Colors.grey,
            textColor: appColors().colorBackground,
            fontSize: 14.0);

        return response.data.toString();

      }
      return response.data.toString();

    } catch (error, stacktrace) {

      Fluttertoast.showToast(
          msg: "Something went wrong.",
          toastLength:
          Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor:
          Colors.grey,
          textColor: appColors().colorBackground,
          fontSize: 14.0);

      return '';
    }
  }

}


