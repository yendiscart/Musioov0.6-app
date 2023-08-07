import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/Model/ModelPlanList.dart';
import 'package:musioo/Model/ModelSettings.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/AppSettingsPresenter.dart';
import 'package:musioo/Presenter/PlanPresenter.dart';
import 'package:musioo/Resources/Strings/StringsLocalization.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'PaymentPlan.dart';

class GoPro extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyState();
  }
}

class MyState extends State {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String checkBox = '', planindex = '',planIdCheck='';
  SharedPref sharePrefs = SharedPref();
  late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
  late UserModel model;
  String token = '';
  List<SubData> listPlans = [];
  late CurrentPlanData currentPlanData;
  String benefitsDetails="";
  late ModelSettings modelSettings;
  bool noData = true,loadingPlan=true;
  String dayMon = '';
  String currencySym = '\$';

  Future<dynamic> value() async {
    token = await sharePrefs.getToken();
    String settingDetails = await AppSettingsPresenter().getAppSettings(token);
    sharePrefs.setSettingsData(settingDetails);
    String? sett = await sharePrefs.getSettings();

    final Map<String, dynamic> parsed = json.decode(sett!);
     modelSettings = ModelSettings.fromJson(parsed);
     if(modelSettings.data.plan_detail.is_download == 1){
    benefitsDetails="Free Downloads.";}
     if(modelSettings.data.plan_detail.show_advertisement == 1){
       benefitsDetails=benefitsDetails+"\nHigh Quality Music.";
     }else{
       benefitsDetails=benefitsDetails+"\nADS free Music.\nHigh Quality Music.";
     }
    currencySym = modelSettings.data.currencySymbol;

    planAPI();

    model = await sharePrefs.getUserData();
    sharedPreThemeData = await sharePrefs.getThemeData();

    return model;
  }


  @override
  void initState() {
    super.initState();
    value();
  }

  Future<void> planAPI() async {
    String response = await PlanPresenter().getAllPlans(token);
    final Map<String, dynamic> parsed = json.decode(response.toString());
    ModelPlanList mList = ModelPlanList.fromJson(parsed);
    listPlans = mList.data.first.all_plans;
    currentPlanData = mList.data.first.current_plan;
    if(currentPlanData.plan_name.isNotEmpty){
      noData = false;
    }else{  noData = true;
    }

    loadingPlan=false;
    dayMon = (currentPlanData.is_month_days == 0) ? 'Days' : 'Months';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: (sharedPreThemeData.themeImageBack.isEmpty)
                  ? AssetImage(AppSettings.imageBackground)
                  : AssetImage(sharedPreThemeData.themeImageBack),
              fit: BoxFit.fill,
            ),
          ),
          padding: EdgeInsets.fromLTRB(10, 6, 10, 6),
          child: Stack(
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(6, 6, 6, 6),
                      child: Text(
                        'Plans',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: (sharedPreThemeData.themeImageBack.isEmpty)
                                ? Color(int.parse(AppSettings.colorText))
                                : Color(int.parse(
                                    sharedPreThemeData.themeColorFont))),
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
                            width: 21,
                            height: 21,
                            color: (sharedPreThemeData.themeImageBack.isEmpty)
                                ? Color(int.parse(AppSettings.colorText))
                                : Color(int.parse(
                                    sharedPreThemeData.themeColorFont)),
                          ),
                        )),
                  ),
                ],
              ),
              if(!loadingPlan)if((noData ||  (modelSettings.data.plan_expiry_date.isEmpty)))Align(
                alignment: Alignment.topLeft,
                child: (modelSettings.data.plan_expiry_date.isEmpty)
                    ? Container(
                        padding: EdgeInsets.fromLTRB(8, 53, 6, 22),
                        child: Text(
                          'No Plan Available! Buy now',
                          style: TextStyle(
                              fontFamily: 'Nunito-Bold',
                              fontSize: 20,
                              color: appColors().colorText),
                        ),
                      ):Container()
    ),
    if(!loadingPlan)if((!(modelSettings.data.plan_expiry_date.isEmpty)))  Container(
                        height: 201,
                        margin: EdgeInsets.fromLTRB(8, 52, 5, 0),
                        padding: EdgeInsets.all(10),
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
                              child: Text(
                                '$currencySym' +modelSettings.data.plan_detail.plan_amount,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontFamily: 'Nunito-Bold',
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xdcffffff)),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 1, 0, 2),
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Current Purchased Plan',
                                      style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 14,
                                          color: appColors().white),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '' + modelSettings.data.plan_detail.plan_name,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: 'Nunito-Bold',
                                          fontSize: 18,
                                          color: appColors().white),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),

                                  ),
                                  if(!loadingPlan)if(modelSettings.data.plan_detail.plan_name.isNotEmpty)Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                    child: Text(
                                      "Benefits: \n"+benefitsDetails
                                      ,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: 'Nunito-Bold',
                                          fontSize: 15,
                                          color: appColors().white),
                                    ),
                                  ),
                                  if(!loadingPlan)Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      (modelSettings.data.plan_detail.validity > 1 && currentPlanData.is_month_days == 0) ? 'Validity ' + modelSettings.data.plan_detail.validity.toString() + " " + dayMon :'Validity ' + modelSettings.data.plan_detail.validity.toString() + " Day",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: 'Nunito-Bold',
                                          fontSize: 15,
                                          color: appColors().white),
                                    ),
                                  ),
                                  if(!loadingPlan)if(modelSettings.data.purchased_plan_date.isNotEmpty)Container(
                                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      (modelSettings.data.purchased_plan_date.isEmpty)?" Expired":"Purchased On "+modelSettings.data.purchased_plan_date
                                      ,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: 'Nunito-Bold',
                                          fontSize: 15,
                                          color: appColors().white),
                                    ),
                                  ),
                                  if(!loadingPlan)if(modelSettings.data.purchased_plan_date.isNotEmpty)Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      (modelSettings.data.plan_expiry_date.isEmpty)?"":"Expire On "+modelSettings.data.plan_expiry_date
                                      ,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: 'Nunito-Bold',
                                          fontSize: 15,
                                          color: appColors().white),
                                    ),
                                  ),

                                ],
                              ),
                            )
                          ],
                        )),

              if(  (listPlans.length > 0))Container(
                padding: (noData ||  (modelSettings.data.plan_expiry_date.isEmpty))
                    ? EdgeInsets.fromLTRB(8, 99, 6, 10)
                    : EdgeInsets.fromLTRB(8, 260, 6, 15),
                child: Text(
                  AppConstant.appName+' Benefits',
                  style: TextStyle(
                      color: (sharedPreThemeData.themeImageBack.isEmpty)
                          ? Color(int.parse(AppSettings.colorText))
                          : Color(int.parse(sharedPreThemeData.themeColorFont)),
                      fontSize: 18,
                      fontFamily: 'Nunito-Bold'),
                ),
              ),
              //here

              //here

              (listPlans.length > 0)
                  ? Container(
                      margin: (noData||  (modelSettings.data.plan_expiry_date.isEmpty))
                          ? EdgeInsets.fromLTRB(0, 129, 1, 1)
                          : EdgeInsets.fromLTRB(0, 280, 1, 1),
                      child: ListView.builder(
                          itemCount: listPlans.length,
                          shrinkWrap: false,
                          itemBuilder: (context, index) {
                            return (int.parse(listPlans[index].plan_amount) <= 0)?Container():Container(
                              //  height: (checkBox.contains('basicplan'))?180:90,
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 7, 0, 2),
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 7),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: planIdCheck.contains(
                                                listPlans[index].id.toString())
                                            ? [
                                                appColors().PrimaryDarkColorApp,
                                                appColors().primaryColorApp,
                                                appColors().primaryColorApp
                                              ]
                                            : [
                                                appColors().colorBackEditText,
                                                appColors().colorBackEditText
                                              ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: checkBox.contains(
                                              listPlans[index].plan_name)
                                          ? null
                                          : Border.all(
                                              color: appColors().colorBorder),
                                    ),
                                    child: TextButton(
                                      child: Column(
                                        children: [
                                          Container(
                                              height: 60,
                                              child: Stack(children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    '$currencySym' + listPlans[index].plan_amount.toString(),
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Nunito-Bold.ttf',
                                                        fontSize: 19.5,
                                                        color: planIdCheck.contains(
                                                                listPlans[index]
                                                                    .id.toString())
                                                            ? appColors().white
                                                            : appColors()
                                                                .primaryColorApp),
                                                  ),
                                                ),
                                                if (!checkBox.isEmpty)if(int.parse(listPlans[int.parse(planindex)].plan_amount) > 0)
                                                  Align(alignment: Alignment.topRight,
                                                    child: InkResponse(onTap: () {
                                                        if(int.parse(planindex) == index){
                                                          if(listPlans[int.parse(
                                                              planindex)]
                                                              .plan_amount.isNotEmpty) {
                                                            if(int.parse(listPlans[int.parse(
                                                                planindex)]
                                                                .plan_amount) > 0) {
                                                              Navigator.push(
                                                                context,
                                                                new MaterialPageRoute(
                                                                  builder: (
                                                                      context) =>
                                                                      Payment(
                                                                          checkBox,
                                                                          listPlans[int
                                                                              .parse(
                                                                              planindex)]
                                                                              .plan_amount,
                                                                          '' +
                                                                              listPlans[int
                                                                                  .parse(
                                                                                  planindex)]
                                                                                  .id
                                                                                  .toString()),
                                                                ),
                                                              );
                                                            }else{
                                                              Fluttertoast.showToast(
                                                                  msg: 'Amount not valid for payment',
                                                                  toastLength: Toast.LENGTH_SHORT,
                                                                  timeInSecForIosWeb: 1,
                                                                  backgroundColor: Colors.grey,
                                                                  textColor: appColors().colorBackground,
                                                                  fontSize: 14.0);
                                                            }
                                                          }
                                                        }else{
                                                          Fluttertoast.showToast(
                                                              msg: 'Select plan to continue..',
                                                              toastLength: Toast.LENGTH_SHORT,
                                                              timeInSecForIosWeb: 1,
                                                              backgroundColor: Colors.grey,
                                                              textColor: appColors().black,
                                                              fontSize: 14.0);
                                                        }
                                                      },
                                                      child: Container(
                                                          alignment: Alignment
                                                              .center,
                                                          width: (planIdCheck.contains(
                                                              listPlans[index].id.toString())) ?100:24,
                                                          height: 36,
                                                          margin: EdgeInsets.fromLTRB(10, 13, 0, 7),
                                                          decoration:
                                                              BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                    colors: (planIdCheck.contains(
                                                                      listPlans[index].id.toString())) ?[
                                                                      appColors()
                                                                          .white,
                                                                      appColors()
                                                                          .white,
                                                                    ]:[
                            appColors().colorBackEditText,
                            appColors().colorBackEditText,
                            ],
                                                                    begin: Alignment
                                                                        .centerLeft,
                                                                    end: Alignment
                                                                        .centerRight,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30.0)),
                                                          child: Text(
                                                            (planIdCheck.contains(
                                                                listPlans[index].id.toString())) ? 'Buy':'',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Nunito',
                                                                fontSize: 16.5,
                                                                color:(planIdCheck.contains(
                                                                    listPlans[index].id.toString())) ?
                                                                    appColors().primaryColorApp:appColors().white),
                                                          )),
                                                    ),
                                                  )
                                              ])),
                                          if (!planIdCheck.contains(
                                              listPlans[index].id.toString()))
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'View Details\n',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        appColors().colorText),
                                              ),
                                            ),
                            if (planIdCheck.contains(
                            listPlans[index].id.toString())) Container(
                            margin: EdgeInsets
                                .fromLTRB(
                            0, 1, 0, 7),
                            height:0.5,
                            color : appColors().colorText
                            ),
                                          if (planIdCheck.contains(
                                              listPlans[index].id.toString()))
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    3, 0, 6, 0),
                                                child: Text(
                                                  listPlans[index].plan_name,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Nunito-Bold.ttf',
                                                      fontSize: 18,
                                                      color: checkBox.contains(
                                                              listPlans[index]
                                                                  .plan_name)
                                                          ? appColors().white
                                                          : appColors()
                                                              .colorText),
                                                ),
                                              ),
                                            ),
                                          planIdCheck.contains(
                                              listPlans[index].id.toString())
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          'assets/images/backimage.png'),
                                                      fit: BoxFit.fill,
                                                      colorFilter: new ColorFilter
                                                              .mode(
                                                          appColors()
                                                              .primaryColorApp
                                                              .withOpacity(0.0),
                                                          BlendMode.dstATop),
                                                    ),
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        appColors()
                                                            .PrimaryDarkColorApp,
                                                        appColors()
                                                            .primaryColorApp,
                                                        appColors()
                                                            .primaryColorApp
                                                      ],
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    border: checkBox.contains(
                                                            listPlans[index]
                                                                .plan_name)
                                                        ? null
                                                        : Border.all(
                                                            color: appColors()
                                                                .colorBorder),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(2),
                                                        child: Text(
                                                          (listPlans[index].validity ==1)?"- " + listPlans[index].validity.toString() + ' Day Validity'  :"- " + listPlans[index].validity.toString() + ' Days Validity',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Nunito',
                                                              fontSize: 16,
                                                              color: checkBox.contains(
                                                                      listPlans[
                                                                              index]
                                                                          .plan_name)
                                                                  ? appColors()
                                                                      .white
                                                                  : appColors()
                                                                      .colorText),
                                                        ),
                                                      ),
                                                      if (listPlans[index].is_download == 1)
                                                        Container(
                                                          padding: EdgeInsets.all(2),
                                                          child: Text(
                                                            '- Unlimited Free Downloads',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Nunito',
                                                                fontSize: 16,
                                                                color: checkBox.contains(
                                                                        listPlans[index]
                                                                            .plan_name)
                                                                    ? appColors()
                                                                        .white
                                                                    : appColors()
                                                                        .colorText),
                                                          ),
                                                        ),
                                                      if (listPlans[index]
                                                              .show_advertisement != 1)
                                                        Container(
                                                          padding:
                                                          EdgeInsets.all(2),
                                                          child: Text(
                                                            '- Ads Free Music',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Nunito',
                                                                fontSize: 16,
                                                                color: checkBox.contains(
                                                                        listPlans[index]
                                                                            .plan_name)
                                                                    ? appColors()
                                                                        .white
                                                                    : appColors()
                                                                        .colorText),
                                                          ),
                                                        ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(2),
                                                        child: Text(
                                                          '- Highest Quality Audio',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Nunito',
                                                              fontSize: 16,
                                                              color: checkBox.contains(
                                                                      listPlans[index]
                                                                          .plan_name)
                                                                  ? appColors()
                                                                      .white
                                                                  : appColors()
                                                                      .colorText),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                      onPressed: () {
                                        print('Click  = ..... ');

                                        if(planIdCheck == listPlans[index].id.toString()){
                                          print('Click   ..... ');
                                          planindex="";
                                          planIdCheck ="";
                                          checkBox="";
                                        }else {
                                          checkBox = listPlans[index].plan_name;
                                          planIdCheck=listPlans[index].id.toString();
                                          planindex = '' + index.toString();
                                        }
                                      setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    )
                  : Container(
                alignment: Alignment.center,
                child: Text(loadingPlan?'Loading...':"", style: TextStyle(
                    fontFamily:
                    'Nunito-Bold',
                    fontSize: 19,
                    color:appColors()
                        .colorTextHead),
                ),
              ),

            ],
          )),
    ));
  }
}

class Resources {
  BuildContext _context;

  Resources(this._context);

  StringsLocalization get strings {
    switch ('en') {
      case 'ar':
        return ArabicStrings();
      case 'fn':
        return FranchStrings();
      default:
        return EnglishStrings();
    }
  }

  static Resources of(BuildContext context) {
    return Resources(context);
  }
}
