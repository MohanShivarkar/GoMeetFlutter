import 'package:dating/presentation/screens/splash_bording/onBordingProvider/onbording_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../Logic/cubits/onBording_cubit/onbording_cubit.dart';

class ExtraAppScreen extends StatefulWidget {
  const ExtraAppScreen({super.key});
  // static const String extraappscreenRoute = "/extraAppScreen";
  @override
  State<ExtraAppScreen> createState() => _ExtraAppScreenState();
}

class _ExtraAppScreenState extends State<ExtraAppScreen> {

  @override
  void initState() {
    super.initState();
    BlocProvider.of<OnbordingCubit>(context).smstypeapi(context);
  }

  late OnbordingCubit onbordingCubit;

  @override
  Widget build(BuildContext context) {
    onbordingCubit = Provider.of<OnbordingCubit>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/lottie/maintance_mode.json"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/icons/Heart-fill1.svg"),
                SizedBox(width: 5,),
                Center(child: Text("Love Under Construction",style: TextStyle(fontSize: 20),)),
                SizedBox(width: 5,),
                SvgPicture.asset("assets/icons/Heart-fill1.svg"),
              ],
            ),
            SizedBox(height: 10,),
            Center(child: Text("We're making improvements to enhance your dating experience. Back soon!",style: TextStyle(fontSize: 16),textAlign: TextAlign.center,)),
          ],
        ),
      ),
    );
  }
}
