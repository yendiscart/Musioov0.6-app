import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/PlanPresenter.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'HomeDiscover.dart';

String plan_id='';
String payment_id='';
String order_id='';
String amountPaid='';
String jsonpayData='';
String payment_type='razorpay';

class PaymentSuccess extends StatefulWidget {

  PaymentSuccess(String paymentType,String planId, String paymentId, String orderId, String amountToPaid, String jsonData){
    plan_id=planId;
    payment_id=paymentId;
    order_id=orderId;
    amountPaid=amountToPaid;
    jsonpayData=jsonData;
    payment_type=paymentType;
  }

 
  
  @override
  State<StatefulWidget> createState() {
    return MyState();
  }
}

class MyState extends State {
  static String token='';
  late UserModel model;
  SharedPref sharePrefs = SharedPref();
  
  Future<void> api()  async {



await PlanPresenter().savePlan(payment_type, plan_id,
        jsonpayData
        , order_id, token);


  }

  Future<dynamic> value() async {
    token = await sharePrefs.getToken();
    model = await sharePrefs.getUserData();
    api();

    return token;
  }
  @override
  void initState() {
    value();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  return SafeArea(
    child: Scaffold(
        backgroundColor: appColors().colorBackground,
        body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
              Image.asset('assets/images/SuccessfullysetBackground.jpg',height: 390),
              Align(
                  child: InkResponse(onTap:() {

                    Navigator.pushReplacement(
                      context,
                      new MaterialPageRoute(
                        builder: (context) => HomeDiscover(),
                      ),
                    );

                  } ,child: Container(

                      margin: EdgeInsets.fromLTRB(6, 0, 6, 0),child:Text(

                    'Plan Purchased successfully!!\nClick here to Continue..',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 23,
                        fontWeight: FontWeight.bold,

                        color: appColors().colorText),)
                  ),
                  )
              ),

            ],)
        )
    ),

  );
  }

}