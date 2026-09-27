import 'package:dating/Logic/cubits/Home_cubit/home_cubit.dart';
import 'package:dating/Logic/cubits/auth_cubit/auth_cubit.dart';
import 'package:dating/Logic/cubits/editProfile_cubit/editprofile_cubit.dart';
import 'package:dating/Logic/cubits/language_cubit/language_bloc.dart';
import 'package:dating/Logic/cubits/match_cubit/match_cubit.dart';
import 'package:dating/Logic/cubits/onBording_cubit/onbording_cubit.dart';
import 'package:dating/Logic/cubits/litedark/lite_dark_cubit.dart';
import 'package:dating/Logic/cubits/litedark/lite_dark_state.dart';
import 'package:dating/Logic/cubits/premium_cubit/premium_bloc.dart';
import 'package:dating/core/routes.dart';
import 'package:dating/firebase_options.dart';
import 'package:dating/language/localization/app_localization_setup.dart';
import 'package:dating/presentation/firebase/auth_firebase.dart';
import 'package:dating/presentation/firebase/chat_service.dart';
import 'package:dating/presentation/firebase/chatting_provider.dart';
import 'package:dating/presentation/firebase/vc_provider.dart';
import 'package:dating/presentation/screens/AudioCall/audiocall_provider.dart';
import 'package:dating/presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';
import 'package:dating/presentation/screens/BottomNavBar/match/matchprovider.dart';
import 'package:dating/presentation/screens/other/editProfile/editprofile_provider.dart';
import 'package:dating/presentation/screens/other/likeMatch/likematch_provider.dart';
import 'package:dating/presentation/screens/other/premium/premium_provider.dart';
import 'package:dating/presentation/screens/other/profileAbout/detailprovider.dart';
import 'package:dating/presentation/screens/other/profileScreen/profile_provider.dart';
import 'package:dating/presentation/screens/pwa/core_pwa_home_screen.dart';
import 'package:dating/presentation/screens/splash_bording/onBordingProvider/onbording_provider.dart';
import 'package:dating/wallete_code/wallet_provider.dart';
import 'package:dating/by_coin_screen/coin_provider.dart';
import 'package:dating/data/localdatabase.dart';
import 'package:dating/features/shell/widgets/offline_banner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

// Mobile-only imports — no-ops on web via conditional import stubs
import 'package:dating/core/push_notification_function.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  // Run persistent storage migrations before bootstrapping providers
  await StorageMigrationService.runMigrations();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  runApp(
    const LoveCloudApp(),
  );

  // Push notifications — guarded inside initPlatformState (if kIsWeb → return)
  await initPlatformState();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class LoveCloudApp extends StatelessWidget {
  const LoveCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => OnbordingCubit()),
        BlocProvider(create: (_) => HomePageCubit()),
        BlocProvider(create: (_) => EditProfileCubit()),
        BlocProvider(create: (_) => MatchCubit()),
        BlocProvider(create: (_) => LanguageCubit()),
        BlocProvider(create: (_) => PremiumBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, theme) {
          return BlocBuilder<LanguageCubit, LanguageState>(
            buildWhen: (prev, curr) => prev != curr,
            builder: (context, languageState) {
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (_) => OnBordingProvider()),
                  ChangeNotifierProvider(create: (_) => DetailProvider()),
                  ChangeNotifierProvider(create: (_) => HomeProvider()),
                  ChangeNotifierProvider(create: (_) => ProfileProvider()),
                  ChangeNotifierProvider(create: (_) => EditProfileProvider()),
                  ChangeNotifierProvider(create: (_) => MatchProvider()),
                  ChangeNotifierProvider(create: (_) => LikeMatchProvider()),
                  ChangeNotifierProvider(create: (_) => FirebaseAuthService()),
                  ChangeNotifierProvider(create: (_) => ChattingProvider()),
                  ChangeNotifierProvider(create: (_) => VcProvider()),
                  ChangeNotifierProvider(create: (_) => AudioCallProvider()),
                  ChangeNotifierProvider(create: (_) => PremiumProvider()),
                  ChangeNotifierProvider(create: (_) => WalleteProvider()),
                  ChangeNotifierProvider(create: (_) => ByCoinProvider()),
                  ChangeNotifierProvider(create: (_) => ChatServices()),
                ],
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  navigatorKey: navigatorKey,
                  home: const CorePwaHomeScreen(),
                  onGenerateRoute: Routes.onGenerateRoute,
                  theme: theme.themeData,
                  supportedLocales: AppLocalizationSetup.supportedLanguage,
                  localizationsDelegates: AppLocalizationSetup.localizationsDelegates,
                  localeResolutionCallback: AppLocalizationSetup.localeResolutionCallback,
                  locale: languageState.locale,
                  builder: (context, child) {
                    Widget current = child ?? const SizedBox();
                    if (kIsWeb) {
                      current = Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: current,
                        ),
                      );
                    }
                    return OfflineBanner(child: current);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
