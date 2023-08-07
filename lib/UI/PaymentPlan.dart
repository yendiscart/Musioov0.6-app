import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/Model/ModelCouponList.dart';
import 'package:musioo/Model/ModelSettings.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/PlanPresenter.dart';
import 'package:musioo/paymentgateway/PayStack.dart';
import 'package:musioo/paymentgateway/Paypal.dart';
import 'package:musioo/paymentgateway/Razorpay.dart';
import 'package:musioo/paymentgateway/Stripe.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';

String planName = '', plan_id = '';
String amount = '0';

class Payment extends StatefulWidget {
  Payment(String checkBox, String plan_amount, String planid) {
    planName = checkBox;
    amount = plan_amount;
    plan_id = planid;
  }

  @override
  State<StatefulWidget> createState() {
    return MyState();
  }
}

class MyState extends State {
  SharedPref sharePrefs = SharedPref();
  late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
  late UserModel model;
  String amountToBePaid = amount.toString();
  String token = '';
  List<DataPlan> listCoupon = [];
  TextEditingController codeController = TextEditingController();
  bool isCode = false;
  String discAmount = '';
  String currencySym = '\$',tax='0';
  String coupon_id = '', discount = '';
  late ModelSettings modelSettings;
  bool hasData=false;

  Future<dynamic> value() async {
    token = await sharePrefs.getToken();
    String? sett = await sharePrefs.getSettings();
    couponAPI();
    final Map<String, dynamic> parsed = json.decode(sett!);
     modelSettings = ModelSettings.fromJson(parsed);
    currencySym = modelSettings.data.currencySymbol;
    tax=modelSettings.data.tax;
    double taxAmount=int.parse(tax)/100;
    taxAmount=taxAmount*int.parse(amount);
    amountToBePaid=(int.parse(amount)+taxAmount).toString();
    hasData=true;
    if(tax.isEmpty){
      tax='0';
    }
    model = await sharePrefs.getUserData();
    sharedPreThemeData = await sharePrefs.getThemeData();
    setState(() {});
    return model;
  }

  @override
  void dispose() {
    amountToBePaid = '0';
    isCode = false;

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    value();
  }

  Future<void> couponAPI() async {
    String response = await PlanPresenter().getAllCoupons(token);

    final Map<String, dynamic> parsed = json.decode(response.toString());
    ModelCouponList mList = ModelCouponList.fromJson(parsed);
    listCoupon = mList.data;
    setState(() {});
  }

  void applySuccess() async {
    String res = await PlanPresenter().addPlanCoupon(codeController.text, token);

    final Map<String, dynamic> parsed = json.decode(res);

    if (parsed['status'].toString().contains("true")) {
      Map<String, dynamic> parsed2 = parsed['data'];
      int disAmount = parsed2['discount'];
      int disTyp = parsed2['discount_type'];
      discount = disAmount.toString();

      if (disTyp == 2) {

        double taxAmount=int.parse(tax)/100;
        taxAmount=taxAmount*int.parse(amount);

        double rate = disAmount / 100;
        double amountDisFinal = double.parse(amount) * rate;
        amountDisFinal=(double.parse(amount) - amountDisFinal.round());

        amountToBePaid = (amountDisFinal.round()+taxAmount).toString();

        discAmount = 'Amount  $amount $currencySym\n Discount  '+disAmount.toString() + " %\nTax   $tax %";

        isCode = true;
        Fluttertoast.showToast(
            msg: 'Congratulations!!\nCoupon Applied Successfully..',
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: appColors().colorBackground,
            fontSize: 14.0);
        setState(() {});
      } else {
        double amt = double.parse(amount);
        if (disAmount < amt.round()) {
          double taxAmount=int.parse(tax)/100;

          double amountafter = double.parse(amount) - disAmount;
          taxAmount=taxAmount*amountafter;
          amountToBePaid = (amountafter.round()+taxAmount).toString();
          discAmount = 'Amount  $amount $currencySym\n Discount '+disAmount.toString() + " $currencySym\nAfter discount ${amountafter.round()} $currencySym\nTax   $tax %";
          isCode = true;
          Fluttertoast.showToast(
              msg: 'Congratulations!!\n Coupon Applied Successfully..',
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: appColors().colorBackground,
              fontSize: 14.0);

        } else {
          Fluttertoast.showToast(
              msg: 'Coupon not valid for this amount',
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: appColors().colorBackground,
              fontSize: 14.0);
        }
        setState(() {});
      }
    } else {
      Fluttertoast.showToast(
          msg: parsed['msg'],
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: appColors().colorBackground,
          fontSize: 14.0);
    }
    // "1 = dollar ,2 = percentage"
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: (sharedPreThemeData.themeImageBack.isEmpty)
              ? AssetImage(AppSettings.imageBackground)
              : AssetImage(sharedPreThemeData.themeImageBack),
          fit: BoxFit.fill,
        ),
      ),
      padding: EdgeInsets.fromLTRB(12, 6, 10, 6),
      child: ListView(children: [
        Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.fromLTRB(6, 6, 6, 6),
                child: Text(
                  'Payment',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: (sharedPreThemeData.themeImageBack.isEmpty)
                          ? Color(int.parse(AppSettings.colorText))
                          : Color(
                              int.parse(sharedPreThemeData.themeColorFont))),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                  margin: EdgeInsets.fromLTRB(8, 9, 6, 6),
                  child: InkResponse(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/icons/backarrow.png',
                      width: 19,
                      height: 20,
                      color: (sharedPreThemeData.themeImageBack.isEmpty)
                          ? Color(int.parse(AppSettings.colorText))
                          : Color(int.parse(sharedPreThemeData.themeColorFont)),
                    ),
                  )),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
              margin: EdgeInsets.fromLTRB(8, 40, 5, 12),
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    appColors().PrimaryDarkColorApp,
                    appColors().primaryColorApp,
                    appColors().primaryColorApp
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Column(children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 1, 0, 6),
                        child: Text(
                          'Charge Plan',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              color: appColors().white),
                        ),
                      ),
                      Text(
                        '$currencySym ' + amount.toString(),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: 'Nunito-Bold',
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: appColors().white),
                      ),
                    ]),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 1, 0, 6),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'You Choose',
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                color: appColors().white),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.fromLTRB(0, 9, 0, 0),
                          child: Text(
                            planName,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: 'Nunito-Bold',
                                fontSize: 20,
                                color: appColors().white),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )),
        ),
        Container(
            height: (listCoupon.length == 0) ? 1 : 135,
            margin: EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: listCoupon.length,
                itemBuilder: (context, idx) {
                  return Container(
                      height: 135,
                      width: 185.5,
                      margin: EdgeInsets.fromLTRB(4, 0, 19, 5),
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/images/BG.png',
                            width: 185.5,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 35, 5),
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: 'Up To',
                                    style: TextStyle(
                                        color: appColors().white,
                                        fontSize: 12,
                                        fontFamily: 'Nunito-Bold.ttf'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: (listCoupon[idx].discount_type == 1)
                                        ? '' +
                                            listCoupon[idx]
                                                .discount
                                                .toString() +
                                            '$currencySym OFF'
                                        : '' +
                                            listCoupon[idx]
                                                .discount
                                                .toString() +
                                            "%",
                                    style: TextStyle(
                                        color: appColors().white,
                                        fontSize: 15.4,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Nunito-Bold.ttf'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 2, 6),
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: 'Valid till ' +
                                        listCoupon[idx].expiry_date,
                                    style: TextStyle(
                                        color: appColors().white,
                                        fontSize: 12,
                                        fontFamily: 'Nunito-Bold.ttf'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 150,
                              margin: EdgeInsets.fromLTRB(2, 6, 41, 0),
                              child: Column(
                                children: [
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: '-- COUPON --',
                                      style: TextStyle(
                                          color: appColors().white,
                                          fontSize: 14.7,
                                          fontFamily: 'Nunito-Bold.ttf'),
                                    ),
                                  ),
                                  Text(
                                    'coupon code',
                                    style: TextStyle(
                                        color: appColors().colorText,
                                        fontSize: 14,
                                        fontFamily: 'Nunito-Bold.ttf'),
                                  ),
                                  Text(
                                    listCoupon[idx].coupon_code,
                                    style: TextStyle(
                                        color: appColors().primaryColorApp,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Nunito-Bold.ttf'),
                                  ),
                                  InkResponse(
                                    child: Container(
                                      width: 100,
                                      height: 29,
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.fromLTRB(1, 6, 12, 1),
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              appColors().PrimaryDarkColorApp,
                                              appColors().PrimaryDarkColorApp,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                      child: Text(
                                        'Redeem Now',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Nunito-Bold',
                                            fontSize: 16.0,
                                            color: appColors().white),
                                      ),
                                    ),
                                    onTap: () {
                                      isCode = false;
                                      setState(() {
                                        codeController.text =
                                            listCoupon[idx].coupon_code;
                                        coupon_id =
                                            listCoupon[idx].id.toString();
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ));
                })),
        Stack(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 40,
                  width: 161,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().colorBackEditText,
                          appColors().colorBackEditText,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: appColors().colorBorder)),
                  margin: EdgeInsets.fromLTRB(13, 17, 3, 0),
                  padding: EdgeInsets.fromLTRB(2, 1, 2, 0),
                  child: TextField(
                      cursorColor: appColors().primaryColorApp,
                      controller: codeController,
                      onChanged: (value) {
                        isCode=false;
                        setState(() {

                        });
                      },
                      style: TextStyle(
                          color: appColors().colorTextSideDrawer,
                          fontSize: 17.0,
                          fontFamily: 'Nunito'),
                      decoration: new InputDecoration(
                        hintText: 'Enter Coupon Code',
                        hintStyle: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 17.0,
                            color: (sharedPreThemeData.themeImageBack.isEmpty)
                                ? Color(int.parse(AppSettings.colorText))
                                : Color(int.parse(
                                    sharedPreThemeData.themeColorFont))),
                      )),
                )),
            if (!isCode)
              Align(
                  alignment: Alignment.centerRight,
                  child: InkResponse(
                    child: Container(
                      width: 140,
                      height: 40,
                      alignment: Alignment.center,
                      margin: EdgeInsets.fromLTRB(1, 15, 1, 16),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              appColors().PrimaryDarkColorApp,
                              appColors().primaryColorApp,
                              appColors().primaryColorApp
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Text(
                        'Apply Now',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Nunito-Bold',
                            fontSize: 16.0,
                            color: appColors().white),
                      ),
                    ),
                    onTap: () {
                      if (codeController.text.isEmpty) {
                        Fluttertoast.showToast(
                            msg: 'Enter Coupon First',
                            toastLength: Toast.LENGTH_SHORT,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey,
                            textColor: appColors().colorBackground,
                            fontSize: 14.0);
                      } else {
                        applySuccess();
                      }
                    },
                  ))
          ],
        ),
        if (isCode)
          Text(
            '',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Nunito-Bold',
                fontSize: 20.0,
                color: (sharedPreThemeData.themeImageBack.isEmpty)
                    ? Color(int.parse(AppSettings.colorText))
                    : Color(int.parse(sharedPreThemeData.themeColorFont))),
          ),
        Text(
        (discAmount.isNotEmpty)?'' +discAmount:"\nAmount $amount $currencySym\nTax  $tax %",
          textAlign: TextAlign.right,
          style: TextStyle(
              fontFamily: 'Nunito-Bold',
              fontSize: 20.0,
              color: (sharedPreThemeData.themeImageBack.isEmpty)
                  ? Color(int.parse(AppSettings.colorText))
                  : Color(int.parse(sharedPreThemeData.themeColorFont)
              )
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(12, 10, 1, 12),
          color: appColors().colorHint,
          height: 0.6,
        ),
        Text(
          'Just Pay ' +amountToBePaid+" $currencySym\n",
          textAlign: TextAlign.right,
          style: TextStyle(
              fontFamily: 'Nunito-Bold',
              fontSize: 20.0,
              color: (sharedPreThemeData.themeImageBack.isEmpty)
                  ? Color(int.parse(AppSettings.colorText))
                  : Color(int.parse(sharedPreThemeData.themeColorFont))),
        ),
        Container(

          margin: EdgeInsets.fromLTRB(8, 9, 6, 8),
    alignment: Alignment.centerLeft,child:Text(
          (!hasData)?'Pay Via : Loading...':"Pay Via :",
          textAlign: TextAlign.right,
          style: TextStyle(
              fontFamily: 'Nunito-Bold',
              fontSize: 20.0,
              color: (sharedPreThemeData.themeImageBack.isEmpty)
                  ? Color(int.parse(AppSettings.colorText))
                  : Color(int.parse(sharedPreThemeData.themeColorFont))),
        ),
        ),
        if(modelSettings.payment_gateways.stripe.stripe_client_id.isEmpty && modelSettings.payment_gateways.paystack.paystack_public_key.isEmpty && modelSettings.payment_gateways.razorpay.razorpay_key.isEmpty && modelSettings.payment_gateways.paypal.paypal_client_id.isEmpty)
          Text('  Currently payment not accepted by admin !',style: TextStyle(
              fontFamily: 'Nunito-Bold',
              fontSize: 19.0,
              color: (sharedPreThemeData.themeImageBack.isEmpty)
                  ? Color(int.parse(AppSettings.colorText))
                  : Color(int.parse(sharedPreThemeData.themeColorFont))),),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
        if(hasData)if(modelSettings.payment_gateways.paypal.paypal_client_id.isNotEmpty)Container(
            margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
            width: 150,
            padding: EdgeInsets.all(12.1),

            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    appColors().white,
                    appColors().white,

                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(5.0)),
            child: InkResponse(
              onTap: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) =>
                        Paypal(
                            planName,
                            amountToBePaid,
                            plan_id,
                            coupon_id,
                            discount,
                            amount,
                            model.data.email,
                            model.data.name),
                  ),
                );
              },

              child: Image.asset(
                'assets/icons/paypal.png',
                width: 19,
                height: 22,

              ),
            )),

          if(hasData)if(modelSettings.payment_gateways.stripe.stripe_client_id.isNotEmpty)Container(
              margin: EdgeInsets.fromLTRB(12, 12, 0, 0),
              width: 150,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      appColors().white,
                      appColors().white,

                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(5.0)),
              child: InkResponse(
                onTap: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) =>
                          StripePay(
                              planName,
                              amountToBePaid,
                              plan_id,
                              coupon_id,
                              discount,
                              amount,
                              model.data.email,
                              model.data.name),
                    ),
                  );
                },

                child: Image.asset(
                  'assets/icons/stripe.png',
                  width: 19,
                  height: 22,

                ),
              )),
        ],),

    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
        if(hasData)if(modelSettings.payment_gateways.paystack.paystack_public_key.isNotEmpty)Container(
            margin: EdgeInsets.fromLTRB(0, 25, 0, 12),
            width: 150,
            padding: EdgeInsets.all(12.1),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    appColors().white,
                    appColors().white,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(5.0)),
            child: InkResponse(
              onTap: () {

                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) =>
                        PayStack(
                            planName,
                            amountToBePaid,
                            plan_id,
                            coupon_id,
                            discount,
                            amount,
                            model.data.email,
                            model.data.name),
                  ),
                );
              },

              child: Image.asset(
                'assets/icons/paystack.png',
                width: 19,
                height: 22,

              ),
            )),
        if(hasData)if(modelSettings.payment_gateways.razorpay.razorpay_key.isNotEmpty) Container(
            margin: EdgeInsets.fromLTRB(12, 25, 0, 12),
            width: 150,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    appColors().white,
                    appColors().white,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(5.0)),
            child: InkResponse(
              onTap: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) =>
                        Razorpayment(
                            planName,
                            amountToBePaid,
                            plan_id,
                            coupon_id,
                            discount,
                            amount,
                            model.data.email,
                            model.data.name),
                  ),
                );
              },

              child: Image.asset(
                'assets/icons/razorpay.png',
                width: 19,
                height: 22,

              ),
            )),
    ])/*
        Align(
            alignment: Alignment.center,
            child: InkResponse(
              child: Container(
                width: 160,
                height: 44,
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(1, 15, 1, 0),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        appColors().PrimaryDarkColorApp,
                        appColors().primaryColorApp,
                        appColors().primaryColorApp
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30.0)),
                child: Text(
                  'Continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Nunito-Bold',
                      fontSize: 18.0,
                      color: appColors().white),
                ),
              ),
              onTap: () {
                String type="stripe";
                if(type.contains("rzp")) {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) =>
                          Razorpayment(
                              planName,
                              amountToBePaid,
                              plan_id,
                              coupon_id,
                              discount,
                              amount,
                              model.data.email,
                              model.data.name),
                    ),
                  );
                }else{
                  if(type.contains("stripe")){
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (context) =>
                            StripePay(
                                planName,
                                amountToBePaid,
                                plan_id,
                                coupon_id,
                                discount,
                                amount,
                                model.data.email,
                                model.data.name),
                      ),
                    );
                  }else{
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (context) =>
                            PayStack(
                                planName,
                                amountToBePaid,
                                plan_id,
                                coupon_id,
                                discount,
                                amount,
                                model.data.email,
                                model.data.name),
                      ),
                    );
                  }
                }
              },
            ))*/
      ]),
    )));
  }
}
