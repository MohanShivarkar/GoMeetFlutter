import 'package:dating/Logic/cubits/auth_cubit/auth_cubit.dart';
import 'package:dating/Logic/cubits/editProfile_cubit/editprofile_cubit.dart';
import 'package:dating/Logic/cubits/Home_cubit/home_cubit.dart';
import 'package:dating/Logic/cubits/language_cubit/language_bloc.dart';
import 'package:dating/Logic/cubits/onBording_cubit/onbording_cubit.dart';
import 'package:dating/Logic/cubits/litedark/lite_dark_cubit.dart';
import 'package:dating/Logic/cubits/match_cubit/match_cubit.dart';
import 'package:dating/Logic/cubits/premium_cubit/premium_bloc.dart';
import 'package:dating/by_coin_screen/coin_provider.dart';
import 'package:dating/core/routes.dart';
import 'package:dating/firebase_options.dart';
import 'package:dating/language/localization/app_localization_setup.dart';
import 'package:dating/presentation/firebase/auth_firebase.dart';
import 'package:dating/presentation/firebase/chat_service.dart';
import 'package:dating/presentation/firebase/chatting_provider.dart';
import 'package:dating/presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';
import 'package:dating/presentation/screens/other/editProfile/editprofile_provider.dart';
import 'package:dating/presentation/screens/other/likeMatch/likematch_provider.dart';
import 'package:dating/presentation/screens/other/premium/premium_provider.dart';
import 'package:dating/presentation/screens/other/profileAbout/detailprovider.dart';
import 'package:dating/presentation/screens/splash_bording/onBordingProvider/onbording_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Logic/cubits/litedark/lite_dark_state.dart';
 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble("rediuse", 0);

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => OnbordingCubit()),
        BlocProvider(create: (context) => LanguageCubit()),
        BlocProvider(create: (context) => HomePageCubit()),
        BlocProvider(create: (context) => EditProfileCubit()),
        BlocProvider(create: (context) => MatchCubit()),
        BlocProvider(create: (context) => PremiumBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(builder: (context, theme) {
      return BlocBuilder<LanguageCubit,LanguageState>(buildWhen: (previous, current) => previous != current, builder: (context, languageState){
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (context) => OnBordingProvider()),
                ChangeNotifierProvider(create: (context) => FirebaseAuthService()),
                ChangeNotifierProvider(create: (context) => HomeProvider()),
                ChangeNotifierProvider(create: (context) => EditProfileProvider()),
                ChangeNotifierProvider(create: (context) => DetailProvider()),
                ChangeNotifierProvider(create: (context) => LikeMatchProvider()),
                ChangeNotifierProvider(create: (context) => PremiumProvider()),
                ChangeNotifierProvider(create: (context) => ByCoinProvider()),
                ChangeNotifierProvider(create: (context) => ChattingProvider()),
                ChangeNotifierProvider(create: (context) => ChatServices()),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: theme.themeData,
                navigatorKey: navigatorKey,
                onGenerateRoute: Routes.onGenerateRoute,
                supportedLocales: AppLocalizationSetup.supportedLanguage,
                localizationsDelegates: AppLocalizationSetup.localizationsDelegates,
                localeResolutionCallback: AppLocalizationSetup.localeResolutionCallback,
                locale: languageState.locale,
              )
            );
          }
        );
      }),
    );
  }
}


