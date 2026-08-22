import 'package:dating/presentation/screens/other/profileScreen/blocklist_page.dart';
import 'package:dating/presentation/screens/other/profileScreen/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../../language/localization/app_localization.dart';
import '../../../widgets/other_widget.dart';

class profile_privacyy extends StatefulWidget {
  const profile_privacyy({Key? key}) : super(key: key);

  @override
  State<profile_privacyy> createState() => _profile_privacyyState();
}

class _profile_privacyyState extends State<profile_privacyy> {

  late ProfileProvider profileProvider;

  @override
  void initState() {
    // TODO: implement initState
    profileProvider = Provider.of<ProfileProvider>(context,listen: false);
    profileProvider.blocklistaApi(context).then((value) {
      setState(() {

      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    profileProvider = Provider.of<ProfileProvider>(context);
    return  Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: const BackButtons(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          AppLocalizations.of(context)?.translate("Profile & Privacy") ?? "Profile & Privacy",
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 20),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: profileProvider.isLoading ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
             ListTile(
               onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const Block_List(),));
               },
               contentPadding: EdgeInsets.zero,
               title: Padding(
                 padding: const EdgeInsets.only(bottom: 4.0),
                 child: Text('Blocked Users (${profileProvider.blocklistApi.blocklist!.length})',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
               ),
               subtitle: Text(AppLocalizations.of(context)?.translate("The people you blocked are displayed here.") ?? "The people you blocked are displayed here.",style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey,fontSize: 14)),
               trailing: SvgPicture.asset("assets/icons/Arrow - Right 2.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),
                 // height: 25,
                 // width: 25,
               ),
             ),
            ],
          ),
        ),
      ) : const Center(child: CircularProgressIndicator(color: Colors.red,)),
    );
  }
}
