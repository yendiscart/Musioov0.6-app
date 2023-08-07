
import 'package:dio/dio.dart';
import 'package:musioo/utils/AppConstant.dart';



class AppSettingsPresenter{
  late Dio _dio = Dio();


  Future<String> getAppSettings(String token) async {

    Response<String> response = await _dio.get(AppConstant.BaseUrl+AppConstant.API_GET_USER_SETTING_DETAILS, options: Options(headers: {
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
      return 'error';
    }
  }
}

