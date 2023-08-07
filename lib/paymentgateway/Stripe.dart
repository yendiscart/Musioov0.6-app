import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:musioo/Presenter/PlanPresenter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Model/ModelSettings.dart';
import '../ThemeMain/appColors.dart';
import '../UI/PaymentSuccess.dart';
import '../utils/SharedPref.dart';

String planname='',plan_id='';
double amountPlan=0,mainAmount=0,exactPlanAmount=0;
String CurrencyCode='USD',currSym='\$',tax='';
String coupon_id='';
String discount='', name = '', email = '';

class StripePay extends StatefulWidget {
   StripePay(String planName, String amountToBePaid, String planid, String id, String discoun, String exactAmount, String ema, String nam) {
     planname = planName;
     amountPlan = double.parse(amountToBePaid);
     mainAmount = double.parse(amountToBePaid);
     plan_id = planid;
     exactPlanAmount = double.parse(exactAmount);
     coupon_id = id;
     discount = discoun;
     name = nam;
     email = ema;
   }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<StripePay> {
  bool hasData=false,payLoading=false;
  String secretKey='';
  Map<String, dynamic>? paymentIntentData;
  late ModelSettings modelSettings;
  SharedPref shareprefs = SharedPref();
  static String token='';
  int _nowstamp = DateTime.now().millisecondsSinceEpoch;


  getValue() async {
    String? sett = await shareprefs.getSettings();
    final Map<String, dynamic> parsed = json.decode(sett!);
     modelSettings = ModelSettings.fromJson(parsed);
    CurrencyCode = modelSettings.data.currencyCode;
    currSym=modelSettings.data.currencySymbol;
    token = await shareprefs.getToken();

if(amountPlan.toString().isNotEmpty){
  double amount=double.parse(amountPlan.toString());
  amountPlan=amount;
}

    // secretKey=""+modelSettings.data.STRIPE_DETAILS.SECRET_KEY;
secretKey=modelSettings.payment_gateways.stripe.stripe_secret;
    WidgetsFlutterBinding.ensureInitialized();
Stripe.publishableKey = modelSettings.payment_gateways.stripe.stripe_client_id;
  //  Stripe.publishableKey = ""+modelSettings.data.STRIPE_DETAILS.PUBLIC_KEY;
 Stripe.merchantIdentifier = modelSettings.payment_gateways.stripe.stripe_merchant_country_identifier;

    await Stripe.instance.applySettings();

    hasData=true;
    setState(() {

    });

    await makePayment();
  }


  Future<void> apicall(String pay_data) async {
    String res= await PlanPresenter().singleSongPay("stripe",""+plan_id,""+pay_data,token);
    Navigator.pop(context,"single");
  }


  @override
  void initState() {
    getValue();
    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: (hasData && payLoading)?InkWell(
          onTap: ()async{

          },
          child: Container(
            height: 50,
            width: 210,
            color: appColors().primaryColorApp,
            child: Center(
              child: Text('Start Shopping again' , style: TextStyle(color: Colors.white , fontSize: 20),),
            ),
          ),
        ):Container(
          child: CircularProgressIndicator(
              valueColor:
              AlwaysStoppedAnimation(
                  appColors().primaryColorApp),
              backgroundColor: appColors().gray,
              strokeWidth: 3.2),

        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {

      paymentIntentData =
      await createPaymentIntent(''+amountPlan.round().toString(), ""+CurrencyCode); //json.decode(response.body);

      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              style: ThemeMode.dark,
              merchantDisplayName: modelSettings.payment_gateways.stripe.stripe_merchant_display_name)).then((value){
      });


      ///now finally display payment sheeet

      displayPaymentSheet();
    } catch (e, s) {

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cancel Payment! Error")));
      Navigator.pop(context);
    }
  }

  displayPaymentSheet() async {

    try {
      await Stripe.instance.presentPaymentSheet(
          parameters: PresentPaymentSheetParameters(
            clientSecret: paymentIntentData!['client_secret'],
            confirmPayment: true,
          )).then((newValue){


        print('payment intent'+paymentIntentData!['id'].toString());
        print('payment intent'+paymentIntentData!['client_secret'].toString());
        print('payment intent'+paymentIntentData!['amount'].toString());
        print('payment intent'+paymentIntentData.toString());
        //orderPlaceApi(paymentIntentData!['id'].toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("paid successfully")));
      //  payment_details="{\"payment_id\" : \""+paymentIntentData!['id'].toString()+"\"}";
//orderPlace();
        if(discount.toString().contains("SingleSongPay")){


          Fluttertoast.showToast(
              msg: 'Payment Done! Please wait',
              toastLength: Toast.LENGTH_LONG);
          apicall('[{"order_id":"'+paymentIntentData!['id'].toString()+
              '","currency":"'+currSym+'"'
              ',"transaction_id":"'+paymentIntentData!['id'].toString()+'"'
              ',"payment_id":"'+paymentIntentData!['id'].toString()+'"'
              ',"amount":"'+exactPlanAmount.toString()+'"'
              ',"payment_gateway":"stripe"'
              ',"status":"1"'
              ',"audio_id":"'+plan_id+'"'
              ',"user_email":"'+email+'"'
              ',"user_name":"'+name+'"'
              '}]');


          paymentIntentData = null;


        }else {
          String json = '[{"order_id":"' +
              _nowstamp.toString() +
              '","plan_id":"' +
              plan_id +
              '","amount":"' +
              mainAmount.toString() +
              '","currency":"' +
              currSym +
              '"'
                  ',"discount":"' +
              discount +
              '","taxAmount":"' '","payment_gateway":"stripe","user_email":"' +
              email +
              '","user_name":"' +
              name +
              '","taxPercent":"' + tax +
              '"'
                  ',"plan_exact_amount":"' +
              exactPlanAmount.toString() +
              '"'
                  ',"payment_id":"' +
              paymentIntentData!['id'].toString() +
              '","coupon_id":"' +
              coupon_id +
              '"'
                  ',"transaction_id":"' +
              paymentIntentData!['id'].toString() +
              '"}]';
String pay_id=paymentIntentData!['id'].toString();
          Navigator.pushReplacement(
            context,
            new MaterialPageRoute(
              builder: (context) =>
                  PaymentSuccess(
                      'Stripe',
                      plan_id,
                      '' + pay_id,
                      '' + _nowstamp.toString(),
                      amountPlan.toString(),
                      json),
            ),
          );
          paymentIntentData = null;
        }

      }).onError((error, stackTrace){

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cancel Payment!")));
        Navigator.pop(context);
      });


    } on StripeException catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text("Cancelled "),
          ));
    } catch (e) {
      print('$e');
    }
  }





  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(''+amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer '+secretKey,
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      print('Create Intent reponse ===> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100 ;
    return a.toString();
  }

}
