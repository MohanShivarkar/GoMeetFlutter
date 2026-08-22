// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:dating/Logic/cubits/premium_cubit/premium_bloc.dart';
import 'package:dating/by_coin_screen/payout_list_api_model.dart';
import 'package:dating/by_coin_screen/paystack_api_model.dart';
import 'package:dating/by_coin_screen/refer_and_earn_api_model.dart';
import 'package:dating/core/config.dart';
import 'package:dating/core/ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../core/api.dart';
import '../presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';
import 'coin_report_api_model.dart';
import 'list_package_api_model.dart';
import 'mygift_list_ api_model.dart';

class ByCoinProvider extends ChangeNotifier {

  final Api _api = Api();
  late ListPackageApiModel listPackageApiModel;
  bool isLoading = false;


  Future ListPackageApi(context) async{
    try{
      var response = await _api.sendRequest.get("${Config.baseUrlApi}${Config.packagelistapi}",);
      if(response.statusCode == 200){
        listPackageApiModel = ListPackageApiModel.fromJson(response.data);
        isLoading = true;
        notifyListeners();
      }
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }


  bool isLoad = false;

  Future packagepurchaseApi({context,required String packageid,required String wall_amt}) async{


    if(isLoad){
      return;
    }else{
      isLoad = true;
    }

    Map data = {
      "package_id" : packageid,
      "uid" : Provider.of<HomeProvider>(context,listen: false).uid,
      "wall_amt" : wall_amt,
    };

    try{
      var response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.packagepurcheaseapi}",data: data);
      if(response.statusCode == 200){
        if(response.data["Result"] == "true"){
          isLoad = false;
          showDialog<String>(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.appColor,
                    ),
                    child: const Center(child: Icon(Icons.check,size: 30,color: Colors.white,),),
                  ),
                  const SizedBox(height: 10,),
                  Text('Plan Purchase Successful!',style: TextStyle(fontSize: 18,fontFamily: "GilroyBold",color: AppColors.appColor),),
                  const SizedBox(height: 20,),
                  Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: AppColors.appColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(AppColors.appColor),shape: const MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))))),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Center(
                          child: RichText(text: const TextSpan(
                              children: [
                                TextSpan(text: "Ok",style: TextStyle(fontSize: 15,)),
                              ]
                          )),
                        ),
                      )
                  )
                ],
              ),
            ),
          );
          Fluttertoast.showToast(msg: response.data["ResponseMsg"]);
        }else{
          Fluttertoast.showToast(msg: response.data["ResponseMsg"]);
        }
      }
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }


  late CoinReportApiModel coinReportApiModel;

  Future coinreportApi(context) async{
    Map data = {
      "uid" : Provider.of<HomeProvider>(context,listen: false).uid,
    };
    try{
      var response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.coinreportapi}",data: data);
      if(response.statusCode == 200){
        coinReportApiModel = CoinReportApiModel.fromJson(response.data);
        notifyListeners();
      }
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }




  // refer and earn

  bool isreferload = false;

  late ReferAndEarnApiModel referAndEarnApiModel;

  Future referandearnApi(context) async{
    Map data = {
      "uid" : Provider.of<HomeProvider>(context,listen: false).uid,
    };
    try{
      var response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.referansearnapi}",data: data);
      if(response.statusCode == 200){
        referAndEarnApiModel = ReferAndEarnApiModel.fromJson(response.data);
        isreferload = true;
        notifyListeners();
      }
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }



  // paystack index api
  String refrenceee = "";



  late PayStackApiApiModel payStackApiApiModel;

  Future paystackApi({context,required String email,required String amount}) async{
    Map data = {
      "email" : email,
      "amount" : amount,
    };
    try{
      var response = await _api.sendRequest.post("${Config.baseUrl}${Config.paystackapi}",data: data);
      if(response.statusCode == 200){
        payStackApiApiModel = PayStackApiApiModel.fromJson(response.data);
        notifyListeners();
        refrenceee = payStackApiApiModel.data.reference;
        print("+++++:-  (${refrenceee})");
        return payStackApiApiModel.data.authorizationUrl;
      }
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }



  // payout list

  bool payoutloading = true;

  late PayOutListApiModel payOutListApiModel;

  Future payoutlistApi(context) async{
    Map data = {
      "uid" : Provider.of<HomeProvider>(context,listen: false).uid,
    };
    try{
      var response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.payoutlistapi}",data: data);
      if(response.statusCode == 200){
        payOutListApiModel = PayOutListApiModel.fromJson(response.data);
        payoutloading = false;
        notifyListeners();
      }
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }




  Future requestwithdrewApi({context,required String coin,required String r_type,required String acc_number,required String bank_name,required String acc_name,required String ifsc_code,required String upi_id,required String paypal_id}) async{


    if(isLoad){
      return;
    }else{
      isLoad = true;
    }

    Map data = {
      "uid" : Provider.of<HomeProvider>(context,listen: false).uid,
      "coin" : coin,
      "r_type" : r_type,
      "acc_number" : acc_number,
      "bank_name" : bank_name,
      "acc_name" : acc_name,
      "ifsc_code" : ifsc_code,
      "upi_id" : upi_id,
      "paypal_id" : paypal_id,
    };

    try{
      var response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.requestwithdrewapi}",data: data);
      if(response.statusCode == 200){
        if(response.data["Result"] == "true"){

          isLoad = false;
          showDialog<String>(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.appColor,
                    ),
                    child: const Center(child: Icon(Icons.check,size: 30,color: Colors.white,),),
                  ),
                  const SizedBox(height: 10,),
                  Text('Coin Withdraw Successful!',style: TextStyle(fontSize: 18,fontFamily: "GilroyBold",color: AppColors.appColor),),
                  const SizedBox(height: 20,),
                  Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: AppColors.appColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(AppColors.appColor),shape: const MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))))),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Center(
                          child: RichText(text: const TextSpan(
                              children: [
                                TextSpan(text: "Ok",style: TextStyle(fontSize: 15,)),
                              ]
                          )),
                        ),
                      )
                  )
                ],
              ),
            ),
          );

          Fluttertoast.showToast(msg: response.data["ResponseMsg"]);
        }else{
          Fluttertoast.showToast(msg: response.data["ResponseMsg"]);
        }
      }
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }



  late MyGiftListApiModel myGiftListApiModel;

  bool giftloading = false;

  Future mygiftApi(context) async{
    Map data = {
      "uid" : Provider.of<HomeProvider>(context,listen: false).uid,
    };
    try{
      var response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.mygiftapi}",data: data);
      if(response.statusCode == 200){
        myGiftListApiModel = MyGiftListApiModel.fromJson(response.data);
        giftloading = true;
        notifyListeners();
      }
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }


  Future paystacktranjaction({context,required String Skkey}) async{

    var headers = {
      'accept': 'application/json',
      'authorization': 'Bearer ${Skkey}',
      'cache-control': 'no-cache',
      'Cookie': '__cf_bm=Hisd6kLoLGtXHPuCu9m2dynN7IiYCtxjRcoJ.FUNL3M-1718969147-1.0.1.1-6DYEw0kqsKA3qBU6m4AXxPO5oQhbMpJBQNmoQgcbaZgq.vkUnOFpDkpZ32YAWDaZlnaGugxIbeQvg_J43yiLWA; sails.sid=s%3AaqmjG9NylSkxfFZ0yjaPIVzkKBAVs1_D.L3UA%2BbyhU1yhWHDQXhtSAdDwHmnhGs4dRHyOPUSHUNk'
    };
    var dio = Dio();
    var response = await dio.request('https://api.paystack.co/transaction/verify/${refrenceee}', options: Options(method: 'GET', headers: headers,),
    );

    if (response.statusCode == 200) {
      print("https://api.paystack.co/transaction/verify/${refrenceee}");
      print("+++++++:---  ${headers}");
      print(json.encode(response.data));
      return response.data;
    }
    else {
      print(response.statusMessage);
    }

  }



}
