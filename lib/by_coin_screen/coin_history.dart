import 'package:dating/core/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../core/config.dart';
import '../language/localization/app_localization.dart';
import '../presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';
import '../presentation/widgets/other_widget.dart';
import 'coin_provider.dart';

class CoinHistory extends StatefulWidget {
  const CoinHistory({super.key});

  @override
  State<CoinHistory> createState() => _CoinHistoryState();
}

class _CoinHistoryState extends State<CoinHistory> with TickerProviderStateMixin{

  late ByCoinProvider byCoinProvider;
  late final TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    byCoinProvider = Provider.of<ByCoinProvider>(context,listen: false);
    byCoinProvider.payoutlistApi(context);
    byCoinProvider.coinreportApi(context);
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    byCoinProvider = Provider.of<ByCoinProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // title: Text("History",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18)),
        title: Text(AppLocalizations.of(context)?.translate("History") ?? "History",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18)),
        leading: const BackButtons(),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: byCoinProvider.payoutloading ?  Center(child: CircularProgressIndicator(color: AppColors.appColor,),) : Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [


            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 5,),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xffF8F8F8),
                      borderRadius: BorderRadius.circular(65)
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: AppColors.appColor,
                        borderRadius: BorderRadius.circular(65),
                      ),
                      controller: _tabController,
                      indicatorColor: Colors.red,
                      labelColor: Colors.white,
                      physics: const BouncingScrollPhysics(),
                      indicatorSize: TabBarIndicatorSize.tab,
                      unselectedLabelColor: Colors.black,
                      dividerColor: Colors.transparent,
                      labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14),
                      tabs: <Widget>[
                        Tab(text: AppLocalizations.of(context)?.translate("Coin History") ?? "Coin History"),
                        Tab(text: AppLocalizations.of(context)?.translate("Withdraw History") ?? "Withdraw History"),
                      ],
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      physics: const BouncingScrollPhysics(),
                      controller: _tabController,
                      children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.only(left: 5,right: 5),
                          child: ListView.separated(
                              separatorBuilder: (context, index) {
                                return const SizedBox(width : 0,);
                              },
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: byCoinProvider.coinReportApiModel.coinitem.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  padding: const EdgeInsets.only(left: 10,right: 10),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                      borderRadius: BorderRadius.circular(22)
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: byCoinProvider.coinReportApiModel.coinitem[index].status == 'Debit' ? const Image(image: AssetImage('assets/Image/Debit.png'),height: 40):const Image(image: AssetImage('assets/Image/Creadit.png'),height: 40),
                                    title: Transform.translate(offset: const Offset(-6, 0),child: Text(byCoinProvider.coinReportApiModel.coinitem[index].message,style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15))),
                                    subtitle: Transform.translate(offset: const Offset(-6, 0),child: Text(byCoinProvider.coinReportApiModel.coinitem[index].status,style: const TextStyle(fontSize: 14,color: Colors.grey))),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SvgPicture.asset("assets/icons/finalcoinicon.svg",height: 20,),
                                        const SizedBox(width: 5,),
                                        Text(byCoinProvider.coinReportApiModel.coinitem[index].status == 'Debit' ? '-' : "+",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: byCoinProvider.coinReportApiModel.coinitem[index].status == "Debit"  ? Colors.red : AppColors.appColor)),
                                        Text(byCoinProvider.coinReportApiModel.coinitem[index].amt,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: byCoinProvider.coinReportApiModel.coinitem[index].status == "Debit"  ? Colors.red : AppColors.appColor)),
                                      ],
                                    ),
                                  ),
                                );
                              }
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 5,right: 5),
                          child: ListView.separated(
                              separatorBuilder: (context, index) {
                                return const SizedBox(width : 0,);
                              },
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: byCoinProvider.payOutListApiModel.payoutlist.length,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () {

                                    showModalBottomSheet(
                                      context: context,
                                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 300),
                                      isScrollControlled: true,
                                      builder: (context) {
                                        return Container(
                                          decoration:  BoxDecoration(
                                            color: Theme.of(context).scaffoldBackgroundColor,
                                            borderRadius: const BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
                                          ),
                                          child:  Padding(
                                            padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                const SizedBox(height: 20,),
                                                Row(
                                                  children: [
                                                    Text(AppLocalizations.of(context)?.translate("Payout id") ?? "Payout id", style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                    const Spacer(),
                                                    Text(byCoinProvider.payOutListApiModel.payoutlist[index].payoutId,style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                                const SizedBox(height: 10,),
                                                Row(
                                                  children: [
                                                    Text(AppLocalizations.of(context)?.translate("Number of coin") ?? "Number of coin", style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                    const Spacer(),
                                                    Text(byCoinProvider.payOutListApiModel.payoutlist[index].coin,style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                                const SizedBox(height: 10,),
                                                Row(
                                                  children: [
                                                    Text(AppLocalizations.of(context)?.translate("Amount") ?? "Amount",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                    const Spacer(),
                                                    Text('${Provider.of<HomeProvider>(context,listen: false).currency}${byCoinProvider.payOutListApiModel.payoutlist[index].amt}',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                                const SizedBox(height: 10,),
                                                Row(
                                                  children: [
                                                    Text(AppLocalizations.of(context)?.translate("Pay by") ?? "Pay by",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                    const Spacer(),
                                                    Text(byCoinProvider.payOutListApiModel.payoutlist[index].rType,style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                    byCoinProvider.payOutListApiModel.payoutlist[index].rType == "BANK Transfer" ?const SizedBox():Text('(${byCoinProvider.payOutListApiModel.payoutlist[index].rType == "UPI" ? byCoinProvider.payOutListApiModel.payoutlist[index].upiId : byCoinProvider.payOutListApiModel.payoutlist[index].paypalId})',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                                byCoinProvider.payOutListApiModel.payoutlist[index].rType == "BANK Transfer" ?   Column(
                                                  children: [
                                                    const SizedBox(height: 10,),
                                                    Row(
                                                      children: [
                                                        Text(AppLocalizations.of(context)?.translate("Account Number") ?? "Account Number",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                        const Spacer(),
                                                        Text(byCoinProvider.payOutListApiModel.payoutlist[index].accNumber,style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10,),
                                                    Row(
                                                      children: [
                                                        Text(AppLocalizations.of(context)?.translate("Bank Name") ?? "Bank Name",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                        const Spacer(),
                                                        Text(byCoinProvider.payOutListApiModel.payoutlist[index].bankName,style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10,),
                                                    Row(
                                                      children: [
                                                        Text(AppLocalizations.of(context)?.translate("Account Name") ?? "Account Name",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                        const Spacer(),
                                                        Text(byCoinProvider.payOutListApiModel.payoutlist[index].accName,style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                  ],
                                                ): const SizedBox(),
                                                const SizedBox(height: 10,),
                                                Row(
                                                  children: [
                                                    Text(AppLocalizations.of(context)?.translate("Request Date") ?? "Request Date",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                    const Spacer(),
                                                    Text('${byCoinProvider.payOutListApiModel.payoutlist[index].rDate}',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                                byCoinProvider.payOutListApiModel.payoutlist[index].status == 'completed' ?  Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 10),
                                                      child: Text(AppLocalizations.of(context)?.translate("Proof") ?? "Proof",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                    ),
                                                    const Spacer(),
                                                    Image(image: NetworkImage('${Config.baseUrl}/${byCoinProvider.payOutListApiModel.payoutlist[index].proof}'),height: 80,width: 80,),
                                                  ],
                                                ) : const SizedBox(),
                                                const SizedBox(height: 20,),
                                              ],
                                            ),
                                          ),
                                        );
                                      },);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.only(left: 10,right: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                      borderRadius: BorderRadius.circular(22)
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: byCoinProvider.payOutListApiModel.payoutlist[index].status == 'completed' ? const Image(image: AssetImage('assets/icons/walletecomplete.png'),height: 40):const Image(image: AssetImage('assets/icons/walletpending.png'),height: 40),
                                      title: Text(capitalize(byCoinProvider.payOutListApiModel.payoutlist[index].status),style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                      subtitle: Text(byCoinProvider.payOutListApiModel.payoutlist[index].rDate.toString().split(" ").first,style: const TextStyle(fontSize: 14,color: Colors.grey)),
                                      trailing: Transform.translate(
                                        offset:  const Offset(5, 0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text('${Provider.of<HomeProvider>(context,listen: false).currency} ${byCoinProvider.payOutListApiModel.payoutlist[index].amt}',style:  TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: AppColors.appColor)),
                                                Row(
                                                  children: [
                                                    SvgPicture.asset("assets/icons/finalcoinicon.svg",height: 15,),
                                                    Text(' ${byCoinProvider.payOutListApiModel.payoutlist[index].coin}',style:  TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: AppColors.appColor)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 5,),
                                            const Icon(Icons.keyboard_arrow_right,color: Colors.grey),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
