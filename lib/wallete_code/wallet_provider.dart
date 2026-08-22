import 'package:dating/core/ui.dart';
import 'package:dating/wallete_code/wallet_report_api_model.dart';
import 'package:dating/wallete_code/wallete_screen.dart';
import 'package:dating/wallete_code/walletup_api_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../core/api.dart';
import '../core/config.dart';
import '../presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';

class WalleteProvider extends ChangeNotifier {

  final Api _api = Api();

  late WalletApiModel walletApiModel;

  Future walletupApi({context,required wallet}) async {

    Map data = {
      "uid" : Provider.of<HomeProvider>(context,listen: false).uid,
      "wallet": wallet,
    };

    try{
      var response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.walletupapi}",data: data);
      if(response.statusCode == 200){
        walletApiModel = WalletApiModel.fromJson(response.data);
        showModalBottomSheet(
          isDismissible: false,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))
          ),
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 360,
              decoration: const BoxDecoration(
                  color: Color(0xffF6F6F6),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20,),
                  const CircleAvatar(radius: 35,backgroundColor: Color(0xff7D2AFF),child: Center(child: Icon(Icons.check,color: Colors.white,)),),
                  const SizedBox(height: 20,),
                  Text('Top up ${Provider.of<HomeProvider>(context,listen: false).currency}${walletController.text}.00',style:  TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: AppColors.black),),
                  const SizedBox(height: 5,),
                  Text('Successfully',style:  TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: AppColors.black),),
                  const SizedBox(height: 28,),
                  Text('${Provider.of<HomeProvider>(context,listen: false).currency}${walletController.text} has been added to your wallet',style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.grey),),
                  const SizedBox(height: 28,),
                  Padding(
                    padding: const EdgeInsets.only(left: 20,right: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: const ButtonStyle(fixedSize: MaterialStatePropertyAll(Size(0, 50)),backgroundColor: MaterialStatePropertyAll(Colors.white),side: MaterialStatePropertyAll(BorderSide(color: Colors.black)),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))))),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Done For Now',style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: ElevatedButton(
                            style: const ButtonStyle(fixedSize: MaterialStatePropertyAll(Size(0, 50)),backgroundColor: MaterialStatePropertyAll(Colors.black),side: MaterialStatePropertyAll(BorderSide(color: Colors.black)),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))))),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Another Top Up',style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                ],
              ),
            );
          },
        );
        notifyListeners();
      }else{
        notifyListeners();
      }

    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }

  }



  late WalletReportApiModel walletReportApiModel;
  bool islaoding = false;

  Future walletreportApi({context}) async{
    Map data = {
      "uid" : Provider.of<HomeProvider>(context,listen: false).uid,
    };
    try{
      var response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.walletreportapi}",data: data);
      print("++++++:-- ${response.data}");
      if(response.statusCode == 200){

        walletReportApiModel = WalletReportApiModel.fromJson(response.data);
        islaoding = true;
        notifyListeners();
      }
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }


}
