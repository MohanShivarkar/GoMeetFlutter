import 'package:dating/core/ui.dart';

import 'package:dating/presentation/widgets/main_button.dart';
import 'package:dating/presentation/widgets/sizeboxx.dart';
import 'package:flutter/material.dart';
import '../../../language/localization/app_localization.dart';
import '../../widgets/fillButton.dart';

class LikesScreen extends StatefulWidget {
  static const likesScreenRoute = "/likeScreen";
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              AppLocalizations.of(context)?.translate("Your admirers haven't noticed you yet") ?? "Your admirers haven't noticed you yet",
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizBoxH(size: 0.02),
            Text(
              AppLocalizations.of(context)?.translate("Find here people who are intrested in you react on their profile for Crusher and to disccus in the maintime, put all the chances on your side with a great profile!") ?? "Find here people who are intrested in you react on their profile for Crusher and to disccus in the maintime, put all the chances on your side with a great profile!",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizBoxH(size: 0.04),
            MainButton(
              title: AppLocalizations.of(context)?.translate("Improve my profile") ?? "Improve my profile",
            ),
            const SizBoxH(size: 0.02),
            FillButton(
              bgColor: AppColors.appColor,
              title: AppLocalizations.of(context)?.translate("Boost your profile") ?? "Boost your profile",
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
