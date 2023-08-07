import 'dart:convert';
import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musioo/Model/ModelPurchaseInfo.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/PurchaseHistoryPresenter.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'package:intl/intl.dart';

class PurchaseHistory extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return purchase_state();
  }

}

class Fact{
  String currency="";
  Fact(this.currency);
  factory Fact.fromJson(Map<dynamic, dynamic> json) {
    return Fact(json['currency']);
  }
}

class purchase_state extends State{
  SharedPref sharePrefs = SharedPref();
  bool isLoading=true;
  String token = '';
  late UserModel model;
  late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
   List<AudioPurchaseHistory> audioPurchaseHistory=[];
  List<PlanPurchaseHistory> planPurchaseHistory=[];
   late DateFormat formatter;

  Future<void> apiCall() async {
    String response =await PurchaseHistoryPresenter().purchaseHistoryInfo(token);
if(response.isEmpty){
  isLoading=false;
  setState(() {});
}else {
  final Map<String, dynamic> parsed = json.decode(response);
  if(parsed['status'].toString().contains("false")){

  }else {
    ModelPurchaseInfo purchaseInfo = ModelPurchaseInfo.fromJson(parsed);
    Fluttertoast.showToast(
        msg: parsed['msg'],
        toastLength: Toast
            .LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor:
        appColors().colorBackground,
        fontSize: 14.0);
    audioPurchaseHistory = purchaseInfo.data.audioPurchaseHistory;
    planPurchaseHistory = purchaseInfo.data.planPurchaseHistory;
  }

  isLoading = false;
  setState(() {});
}
}

  value() async {
    token = await sharePrefs.getToken();
    formatter = DateFormat('yyyy-MM-dd');
    try {
      model = await sharePrefs.getUserData();
      sharedPreThemeData = await sharePrefs.getThemeData();
      apiCall();

    } on Exception catch (e) {}
  }


  @override
  void initState() {
    value();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double size=MediaQuery.of(context).size.width/4 - 5;
    return SafeArea(child:
    Scaffold(body: Container(
    decoration: BoxDecoration(
        image: DecorationImage(
        image: (sharedPreThemeData.themeImageBack.isEmpty) ? AssetImage(AppSettings.imageBackground) : AssetImage(sharedPreThemeData.themeImageBack),
    fit: BoxFit.fill,
    ),
    ),
    child:Stack(
    alignment: Alignment.topRight,
    fit: StackFit.loose,
    children: <Widget>[
    Container(
    height:45,alignment: Alignment.topCenter,margin: EdgeInsets.fromLTRB(0, 12, 2, 2),child: Text('Purchase History',  style: TextStyle(
    fontSize: 20, color:Color(int.parse(AppSettings.colorText)) , fontFamily: 'Nunito',fontWeight: FontWeight.bold )),),
    Container(height:45,alignment: Alignment.topLeft,margin: EdgeInsets.fromLTRB(6, 2, 2, 2),child:IconButton(
    icon: new Icon(Icons.arrow_back_ios_outlined,color:  Color(int.parse(AppSettings.colorText)) ,),
    onPressed: () => Navigator.of(context).pop(),
    ) ,),


      Container(
        margin: EdgeInsets.fromLTRB(2, 45, 2, 12),
        child: CustomScrollView(slivers: [

          if(isLoading)
            SliverToBoxAdapter(
                child:Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center
          ,child: Text("Loading...",style: TextStyle(fontSize: 20,color: Color(int.parse(AppSettings.colorText))
        )),
        )
            )
          ,    SliverToBoxAdapter(
            child: Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.fromLTRB(2, 12, 2, 6),
              child:
              Row(mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(width: size,
                      alignment: Alignment.centerLeft,
                      child: Text("Order Id",
                          style: TextStyle(fontWeight: FontWeight.w900,fontSize: 15,color: appColors().colorTextHead)), ),
                    Container(width: size,
                      alignment: Alignment.center,
                      child: Text("Audio Name",
                          style: TextStyle(fontWeight: FontWeight.w900,fontSize: 15,color: appColors().colorTextHead)), ),
                    Container(width: size,
                      alignment: Alignment.center,
                      child: Text("Amount",  style: TextStyle(fontWeight: FontWeight.w900,fontSize: 15,color:appColors().colorTextHead)),
                    ),
                    Container(width: size,
                      alignment: Alignment.centerRight,
                      child:   Text("Date",  style: TextStyle(fontWeight: FontWeight.w900,fontSize: 15,color:appColors().colorTextHead)
                      ),
                    )
                  ]),
            ),
          )  ,if(!isLoading)SliverToBoxAdapter(
              child:(audioPurchaseHistory.length == 0)?
              Container(
                margin: EdgeInsets.fromLTRB(2, 12, 2, 29),
              alignment: Alignment.center,child: Text("History not found of audio !",
                  style: TextStyle(fontSize: 15,color: appColors().colorHint)),)
                  :ListView.builder(
                  itemCount: audioPurchaseHistory.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    String audioData= audioPurchaseHistory[index].audio_data;
                   String  payment_data=audioPurchaseHistory[index].payment_data;
try{
                   final Map<String, dynamic> parsed = json.decode(audioData);
                   List<dynamic> list = json.decode(payment_data);

                   Fact fact = Fact.fromJson(list[0]);
                   return
                     Row(children: [
                       Container(
                         margin: EdgeInsets.fromLTRB(5, 6, 2, 2),width: size,
                         alignment: Alignment.topLeft,
                         child: Text(audioPurchaseHistory[index].order_id,
                             style: TextStyle(fontSize: 15,color: Color(int.parse(AppSettings.colorText)))), ),
                       Container(
                         margin: EdgeInsets.fromLTRB(0, 6, 0, 2),width: size,
                         alignment: Alignment.topCenter,
                         child: Text(parsed["audio_title"].toString(),
                             style: TextStyle(fontSize: 15,color: Color(int.parse(AppSettings.colorText)))), ),
                       Container(width: size,
                         margin: EdgeInsets.fromLTRB(0, 6, 0, 2),
                         alignment: Alignment.topCenter,
                         child: Text(parsed["download_price"].toString()+fact.currency,  style: TextStyle(fontSize: 15,color: Color(int.parse(AppSettings.colorText)))),
                       ),
                       Container(
                         width: size,
                         margin: EdgeInsets.fromLTRB(0, 6, 0, 2),
                         alignment: Alignment.topRight,
                         child:
                         Text(
                             formatter.format(DateTime.parse(audioPurchaseHistory[index].created_at))
                             ,  style: TextStyle(fontSize: 15,color: Color(int.parse(AppSettings.colorText)))),
                       )
                     ],);
}catch(e){
  print("errr");
  return Text("Not found!",style: TextStyle(color: Color(int.parse(AppSettings.colorText))),);

}


                  })
          ), SliverToBoxAdapter(
            child: Container(
              height: 0.3,
              margin: EdgeInsets.fromLTRB(0, 12, 0, 6),
              color: appColors().colorText,
            ),
          ), SliverToBoxAdapter(
            child: Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.fromLTRB(2, 18, 2, 6),
              child:
              Row(mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(width: size,
                      alignment: Alignment.topLeft,
                      child: Text("Order Id",
                          style: TextStyle(fontWeight: FontWeight.w900,fontSize: 15,color: Color(int.parse(AppSettings.colorText)))), ),
                    Container(width: size,
                      alignment: Alignment.center,
                      child: Text("Plan Name",
                          style: TextStyle(fontWeight: FontWeight.w900,fontSize: 15,color: Color(int.parse(AppSettings.colorText)))), ),
                    Container(width: size,
                      alignment: Alignment.center,
                      child: Text("Amount",  style: TextStyle(fontWeight: FontWeight.w900,fontSize: 15,color: Color(int.parse(AppSettings.colorText)))),
                    ),
                    Container(width: size,
                      alignment: Alignment.topRight,
                      child:   Text("Date",  style: TextStyle(fontWeight: FontWeight.w900,fontSize: 15,color: Color(int.parse(AppSettings.colorText)))),
                    )
                  ]),
            ),
          )  ,if(!isLoading)SliverToBoxAdapter(
        child:(planPurchaseHistory.length == 0)?
        Container(
          margin: EdgeInsets.fromLTRB(2, 12, 2, 29),
          alignment: Alignment.center,child: Text("History not found of plan !",
            style: TextStyle(fontSize: 15,color: appColors().colorHint)),)
            :ListView.builder(
    itemCount: planPurchaseHistory.length,
            shrinkWrap: true,
    itemBuilder: (context, index) {
      String planData= planPurchaseHistory[index].plan_data;
      String payment_data= planPurchaseHistory[index].payment_data;


      final Map<String, dynamic> parsed = json.decode(planData);
      List<dynamic> list = json.decode(payment_data);
      Fact fact = Fact.fromJson(list[0]);

      return
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Container(
            margin: EdgeInsets.fromLTRB(4, 12, 2, 0),width: size,
            alignment: Alignment.topLeft,
            child: Text(planPurchaseHistory[index].order_id,
                style: TextStyle(fontSize: 15,color: Color(int.parse(AppSettings.colorText)))), ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 4, 0, 2),width: size,
            alignment: Alignment.topCenter,
            child: Text(parsed["plan_name"],
            style: TextStyle(fontSize: 15,color: Color(int.parse(AppSettings.colorText)))), ),
      Container(width: size,
        margin: EdgeInsets.fromLTRB(0, 4, 0, 2),
        alignment: Alignment.topCenter,
        child: Text(parsed["plan_amount"]+fact.currency,  style: TextStyle(fontSize: 15,color: Color(int.parse(AppSettings.colorText)))),
      ),
      Container(
        width: size,
        margin: EdgeInsets.fromLTRB(0, 4, 0, 2),
        alignment: Alignment.topRight,
        child:
        Text(
      formatter.format(DateTime.parse(planPurchaseHistory[index].created_at))
            ,  style: TextStyle(fontSize: 15,color: Color(int.parse(AppSettings.colorText)))),
      )
      ],);
    })
          ),
     ] )
    )

    ])
    )
      ,));

  }

}