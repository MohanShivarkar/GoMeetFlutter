# GoMeet Master Module & Feature Tracking List

## 1. Core App Infrastructure
### 1.1 Entry Point
| Component | File | Purpose | Status |
|-----------|------|---------|--------|
| Main App | [main.dart](../lib/main.dart) | Initializes Firebase, Mobile Ads, camera, and runs the app; sets up global navigator key | Not Started |

### 1.2 Core Utilities
| Component | File | Purpose | Status |
|-----------|------|---------|--------|
| API Client | [core/api.dart](../lib/core/api.dart) | API communication with backend | Not Started |
| Configuration | [core/config.dart](../lib/core/config.dart) | App configuration (API endpoints, etc.) | Not Started |
| Google Ads | [core/google_ads.dart](../lib/core/google_ads.dart) | Google AdMob integration | Not Started |
| Push Notifications | [core/push_notification_function.dart](../lib/core/push_notification_function.dart) | FCM push notification handling | Not Started |
| Routing | [core/routes.dart](../lib/core/routes.dart) | Custom route generator for app navigation | Not Started |
| UI Components | [core/ui.dart](../lib/core/ui.dart) | Reusable UI utilities and constants | Not Started |

---

## 2. State Management (Blocs/Cubits)
### 2.1 Auth Cubit
| Component | File | Purpose | Status |
|-----------|------|---------|--------|
| Auth Cubit | [Logic/cubits/auth_cubit/auth_cubit.dart](../lib/Logic/cubits/auth_cubit/auth_cubit.dart) | Manages authentication state | Not Started |
| Auth State | [Logic/cubits/auth_cubit/auth_state.dart](../lib/Logic/cubits/auth_cubit/auth_state.dart) | State definitions for auth | Not Started |

### 2.2 Home Cubit
| Component | File | Purpose | Status |
|-----------|------|---------|--------|
| Home Cubit | [Logic/cubits/Home_cubit/home_cubit.dart](../lib/Logic/cubits/Home_cubit/home_cubit.dart) | Manages home screen state | Not Started |
| Home State | [Logic/cubits/Home_cubit/homestate.dart](../lib/Logic/cubits/Home_cubit/homestate.dart) | State definitions for home | Not Started |

### 2.3 Edit Profile Cubit
| Component | File | Purpose | Status |
|-----------|------|---------|--------|
| Edit Profile Cubit | [Logic/cubits/editProfile_cubit/editprofile_cubit.dart](../lib/Logic/cubits/editProfile_cubit/editprofile_cubit.dart) | Manages edit profile state | Not Started |
| Edit Profile State | [Logic/cubits/editProfile_cubit/editprofile_state.dart](../lib/Logic/cubits/editProfile_cubit/editprofile_state.dart) | State definitions for edit profile | Not Started |

### 2.4 Language Cubit
| Component | File | Purpose | Status |
|-----------|------|---------|--------|
| Language Bloc | [Logic/cubits/language_cubit/language_bloc.dart](../lib/Logic/cubits/language_cubit/language_bloc.dart) | Manages app language | Not Started |
| Language State | [Logic/cubits/language_cubit/language_state.dart](../lib/Logic/cubits/language_cubit/language_state.dart) | State definitions for language | Not Started |

### 2.5 Theme (Light/Dark) Cubit
| Component | File | Purpose | Status |
|-----------|------|---------|--------|
| Theme Cubit | [Logic/cubits/litedark/lite_dark_cubit.dart](../lib/Logic/cubits/litedark/lite_dark_cubit.dart) | Manages light/dark theme | Not Started |
| Theme State | [Logic/cubits/litedark/lite_dark_state.dart](../lib/Logic/cubits/litedark/lite_dark_state.dart) | State definitions for theme | Not Started |

### 2.6 Match Cubit
| Component | File | Purpose | Status |
|-----------|------|---------|--------|
| Match Cubit | [Logic/cubits/match_cubit/match_cubit.dart](../lib/Logic/cubits/match_cubit/match_cubit.dart) | Manages matching state | Not Started |
| Match State | [Logic/cubits/match_cubit/match_states.dart](../lib/Logic/cubits/match_cubit/match_states.dart) | State definitions for matches | Not Started |

### 2.7 Onboarding Cubit
| Component | File | Purpose | Status |
|-----------|------|---------|--------|
| Onboarding Cubit | [Logic/cubits/onBording_cubit/onbording_cubit.dart](../lib/Logic/cubits/onBording_cubit/onbording_cubit.dart) | Manages onboarding state | Not Started |
| Onboarding State | [Logic/cubits/onBording_cubit/onbording_state.dart](../lib/Logic/cubits/onBording_cubit/onbording_state.dart) | State definitions for onboarding | Not Started |

### 2.8 Premium Cubit
| Component | File | Purpose | Status |
|-----------|------|---------|--------|
| Premium Bloc | [Logic/cubits/premium_cubit/premium_bloc.dart](../lib/Logic/cubits/premium_cubit/premium_bloc.dart) | Manages premium subscription state | Not Started |
| Premium State | [Logic/cubits/premium_cubit/premium_state.dart](../lib/Logic/cubits/premium_cubit/premium_state.dart) | State definitions for premium | Not Started |

---

## 3. Data Layer
### 3.1 Data Models
| Model | File | Purpose | Status |
|-------|------|---------|--------|
| Block List | [data/models/blocklistmodel.dart](../lib/data/models/blocklistmodel.dart) | Blocked users model | Not Started |
| Details | [data/models/detailsmodel.dart](../lib/data/models/detailsmodel.dart) | User details model | Not Started |
| FAQ | [data/models/faqmodel.dart](../lib/data/models/faqmodel.dart) | FAQ model | Not Started |
| Favorite List | [data/models/favoritelistmodel.dart](../lib/data/models/favoritelistmodel.dart) | Favorite users model | Not Started |
| Get Block List API | [data/models/getblocklistapimodel.dart](../lib/data/models/getblocklistapimodel.dart) | API response for block list | Not Started |
| Get Interest | [data/models/getinterest_model.dart](../lib/data/models/getinterest_model.dart) | Interests model | Not Started |
| Home | [data/models/homemodel.dart](../lib/data/models/homemodel.dart) | Home screen data model | Not Started |
| Identity Verify | [data/models/identi_verify_model.dart](../lib/data/models/identi_verify_model.dart) | Identity verification model | Not Started |
| Language | [data/models/languagemodel.dart](../lib/data/models/languagemodel.dart) | Language model | Not Started |
| Like Me | [data/models/likememodel.dart](../lib/data/models/likememodel.dart) | Users who liked me model | Not Started |
| Map | [data/models/mapmodel.dart](../lib/data/models/mapmodel.dart) | Map screen data model | Not Started |
| New Match | [data/models/newmatchmodel.dart](../lib/data/models/newmatchmodel.dart) | New matches model | Not Started |
| Notification | [data/models/notificationmodel.dart](../lib/data/models/notificationmodel.dart) | Notifications model | Not Started |
| Pages List | [data/models/pageslist.dart](../lib/data/models/pageslist.dart) | Static pages list | Not Started |
| Passed | [data/models/passedmodel.dart](../lib/data/models/passedmodel.dart) | Passed users model | Not Started |
| Payment | [data/models/paymentmodel.dart](../lib/data/models/paymentmodel.dart) | Payment model | Not Started |
| Plan | [data/models/planmodel.dart](../lib/data/models/planmodel.dart) | Premium plan model | Not Started |
| Premium | [data/models/premiummodel.dart](../lib/data/models/premiummodel.dart) | Premium features model | Not Started |
| Profile Block API | [data/models/profileblockapimodel.dart](../lib/data/models/profileblockapimodel.dart) | Profile block API response | Not Started |
| Profile Image | [data/models/profileimag.dart](../lib/data/models/profileimag.dart) | Profile image model | Not Started |
| Relation Goal | [data/models/relationgoalmodel.dart](../lib/data/models/relationgoalmodel.dart) | Relationship goals model | Not Started |
| Religion | [data/models/religionmodel.dart](../lib/data/models/religionmodel.dart) | Religion model | Not Started |
| Report | [data/models/reportapimodel.dart](../lib/data/models/reportapimodel.dart) | Report user model | Not Started |
| Unblock API | [data/models/unblockapimodel.dart](../lib/data/models/unblockapimodel.dart) | Unblock API response | Not Started |
| User | [data/models/usermodel.dart](../lib/data/models/usermodel.dart) | User profile model | Not Started |

### 3.2 Local Storage
| Component | File | Purpose | Status |
|-----------|------|---------|--------|
| Local Database | [data/localdatabase.dart](../lib/data/localdatabase.dart) | Local storage (SharedPreferences wrapper) | Not Started |

---

## 4. Presentation Layer (Screens & Widgets)
### 4.1 Splash & Onboarding Screens
| Screen | File | Purpose | Status |
|--------|------|---------|--------|
| Splash Screen | [presentation/screens/splash_bording/splash_screen.dart](../lib/presentation/screens/splash_bording/splash_screen.dart) | Initial app loading screen | Not Started |
| Onboarding Screens | [presentation/screens/splash_bording/onbording_screens.dart](../lib/presentation/screens/splash_bording/onbording_screens.dart) | First-time user onboarding | Not Started |
| Auth Screen | [presentation/screens/splash_bording/auth_screen.dart](../lib/presentation/screens/splash_bording/auth_screen.dart) | Authentication choice (login/signup) | Not Started |
| Recover Email | [presentation/screens/splash_bording/recover_email.dart](../lib/presentation/screens/splash_bording/recover_email.dart) | Password recovery screen | Not Started |
| Create Steps | [presentation/screens/splash_bording/creat_steps.dart](../lib/presentation/screens/splash_bording/creat_steps.dart) | Profile creation steps | Not Started |
| Onboarding Provider | [presentation/screens/splash_bording/onBordingProvider/onbording_provider.dart](../lib/presentation/screens/splash_bording/onBordingProvider/onbording_provider.dart) | State management for onboarding | Not Started |

### 4.2 Authentication Screens
| Screen | File | Purpose | Status |
|--------|------|---------|--------|
| Login Screen | [presentation/screens/auth/login_screen.dart](../lib/presentation/screens/auth/login_screen.dart) | User login screen | Not Started |

### 4.3 Main Bottom Navigation Screens
| Screen | File | Purpose | Status |
|--------|------|---------|--------|
| Bottom Bar | [presentation/screens/BottomNavBar/bottombar.dart](../lib/presentation/screens/BottomNavBar/bottombar.dart) | Main app navigation bar | Not Started |
| Home Screen | [presentation/screens/BottomNavBar/home_screen.dart](../lib/presentation/screens/BottomNavBar/home_screen.dart) | Home/discovery screen | Not Started |
| Home Provider | [presentation/screens/BottomNavBar/homeProvider/homeprovier.dart](../lib/presentation/screens/BottomNavBar/homeProvider/homeprovier.dart) | State management for home | Not Started |
| Chats Screen | [presentation/screens/BottomNavBar/chats.dart](../lib/presentation/screens/BottomNavBar/chats.dart) | Chat list screen | Not Started |
| Likes Screen | [presentation/screens/BottomNavBar/likes.dart](../lib/presentation/screens/BottomNavBar/likes.dart) | Likes/mutual matches screen | Not Started |
| Map Screen | [presentation/screens/BottomNavBar/mapscreen.dart](../lib/presentation/screens/BottomNavBar/mapscreen.dart) | Nearby users map | Not Started |
| Browse (Match) Screen | [presentation/screens/BottomNavBar/match/browes.dart](../lib/presentation/screens/BottomNavBar/match/browes.dart) | Swipe/browse users | Not Started |
| Match Provider | [presentation/screens/BottomNavBar/match/matchprovider.dart](../lib/presentation/screens/BottomNavBar/match/matchprovider.dart) | State management for matching | Not Started |
| Notification Screen | [presentation/screens/BottomNavBar/notification_page.dart](../lib/presentation/screens/BottomNavBar/notification_page.dart) | Notifications list | Not Started |

### 4.4 Profile & Account Screens
| Screen | File | Purpose | Status |
|--------|------|---------|--------|
| Profile Screen | [presentation/screens/other/profileScreen/profile_page.dart](../lib/presentation/screens/other/profileScreen/profile_page.dart) | User profile view/edit | Not Started |
| Profile Provider | [presentation/screens/other/profileScreen/profile_provider.dart](../lib/presentation/screens/other/profileScreen/profile_provider.dart) | State management for profile | Not Started |
| Block List | [presentation/screens/other/profileScreen/blocklist_page.dart](../lib/presentation/screens/other/profileScreen/blocklist_page.dart) | Blocked users list | Not Started |
| FAQ Page | [presentation/screens/other/profileScreen/faqpage.dart](../lib/presentation/screens/other/profileScreen/faqpage.dart) | FAQ screen | Not Started |
| Pages List | [presentation/screens/other/profileScreen/pagelist.dart](../lib/presentation/screens/other/profileScreen/pagelist.dart) | Static pages (terms, privacy, etc.) | Not Started |
| Profile Privacy | [presentation/screens/other/profileScreen/profile_privacy.dart](../lib/presentation/screens/other/profileScreen/profile_privacy.dart) | Privacy settings | Not Started |
| Edit Profile | [presentation/screens/other/editProfile/editprofile.dart](../lib/presentation/screens/other/editProfile/editprofile.dart) | Edit profile details | Not Started |
| Edit Profile Provider | [presentation/screens/other/editProfile/editprofile_provider.dart](../lib/presentation/screens/other/editProfile/editprofile_provider.dart) | State management for edit profile | Not Started |
| Profile About (Detail Screen) | [presentation/screens/other/profileAbout/detailscreen.dart](../lib/presentation/screens/other/profileAbout/detailscreen.dart) | View other user's profile | Not Started |
| Detail Provider | [presentation/screens/other/profileAbout/detailprovider.dart](../lib/presentation/screens/other/profileAbout/detailprovider.dart) | State management for user details | Not Started |
| Like/Match Screen | [presentation/screens/other/likeMatch/like_match.dart](../lib/presentation/screens/other/likeMatch/like_match.dart) | Like/match interaction | Not Started |
| Like Match Provider | [presentation/screens/other/likeMatch/likematch_provider.dart](../lib/presentation/screens/other/likeMatch/likematch_provider.dart) | State management for likes/matches | Not Started |

### 4.5 Premium & Payment Screens
| Screen | File | Purpose | Status |
|--------|------|---------|--------|
| Premium Screen | [presentation/screens/other/premium/premium.dart](../lib/presentation/screens/other/premium/premium.dart) | Premium subscription plans | Not Started |
| Plan Details | [presentation/screens/other/premium/plandetials.dart](../lib/presentation/screens/other/premium/plandetials.dart) | Premium plan details | Not Started |
| Premium Provider | [presentation/screens/other/premium/premium_provider.dart](../lib/presentation/screens/other/premium/premium_provider.dart) | State management for premium | Not Started |
| Payment Card | [payment/paymentcard.dart](../lib/payment/paymentcard.dart) | Credit/debit card input | Not Started |
| PayPal Screen | [payment/paypal_screen.dart](../lib/payment/paypal_screen.dart) | PayPal payment integration | Not Started |
| Stripe Web | [payment/stripweb.dart](../lib/payment/stripweb.dart) | Stripe payment web view | Not Started |
| Common Web View | [payment/common_webview.dart](../lib/payment/common_webview.dart) | Generic web view for payments | Not Started |
| Input Formatter | [payment/inputformater.dart](../lib/payment/inputformater.dart) | Card input formatting | Not Started |
| PayPal Integration | [paypal/flutter_paypal.dart](../lib/paypal/flutter_paypal.dart) | Complete PayPal payment flow | Not Started |

### 4.6 Wallet & Coins Screens
| Screen | File | Purpose | Status |
|--------|------|---------|--------|
| Wallet Screen | [wallete_code/wallete_screen.dart](../lib/wallete_code/wallete_screen.dart) | User's coin wallet | Not Started |
| Wallet Provider | [wallete_code/wallet_provider.dart](../lib/wallete_code/wallet_provider.dart) | State management for wallet | Not Started |
| Coin Screen | [by_coin_screen/coin_screen.dart](../lib/by_coin_screen/coin_screen.dart) | Buy coins screen | Not Started |
| Coin Provider | [by_coin_screen/coin_provider.dart](../lib/by_coin_screen/coin_provider.dart) | State management for coins | Not Started |
| Coin History | [by_coin_screen/coin_history.dart](../lib/by_coin_screen/coin_history.dart) | Coin transaction history | Not Started |
| My Gifts | [by_coin_screen/mygift.dart](../lib/by_coin_screen/mygift.dart) | Gifts sent/received | Not Started |
| Refer & Earn | [by_coin_screen/refer_and_earn_screen.dart](../lib/by_coin_screen/refer_and_earn_screen.dart) | Referral program | Not Started |

### 4.7 Chat & Communication
| Screen/Component | File | Purpose | Status |
|------------------|------|---------|--------|
| Chat Page | [presentation/firebase/chat_page.dart](../lib/presentation/firebase/chat_page.dart) | 1-on-1 chat screen | Not Started |
| Chat Service | [presentation/firebase/chat_service.dart](../lib/presentation/firebase/chat_service.dart) | Firebase Firestore chat integration | Not Started |
| Chatting Provider | [presentation/firebase/chatting_provider.dart](../lib/presentation/firebase/chatting_provider.dart) | State management for chat | Not Started |
| Chat Bubble | [presentation/firebase/chat_bubble.dart](../lib/presentation/firebase/chat_bubble.dart) | Chat message widget | Not Started |
| Pickup Call Page | [presentation/firebase/pickup_callpage.dart](../lib/presentation/firebase/pickup_callpage.dart) | Incoming call screen | Not Started |
| Video Call Screen | [presentation/firebase/videocall_screen.dart](../lib/presentation/firebase/videocall_screen.dart) | Agora video call | Not Started |
| VC Provider | [presentation/firebase/vc_provider.dart](../lib/presentation/firebase/vc_provider.dart) | State management for video calls | Not Started |
| Audio Call Screen | [presentation/screens/AudioCall/audiocall_screen.dart](../lib/presentation/screens/AudioCall/audiocall_screen.dart) | Agora audio call | Not Started |
| Audio Calling Screen | [presentation/screens/AudioCall/audio_callingscreen.dart](../lib/presentation/screens/AudioCall/audio_callingscreen.dart) | Audio call UI | Not Started |
| Audio Call Provider | [presentation/screens/AudioCall/audiocall_provider.dart](../lib/presentation/screens/AudioCall/audiocall_provider.dart) | State management for audio calls | Not Started |
| Push Notification Screen | [presentation/push_notification_screen.dart](../lib/presentation/push_notification_screen.dart) | Push notification handling UI | Not Started |

### 4.8 Reusable Widgets
| Widget | File | Purpose | Status |
|--------|------|---------|--------|
| App Bar | [presentation/widgets/appbarr.dart](../lib/presentation/widgets/appbarr.dart) | Custom app bar | Not Started |
| Fill Button | [presentation/widgets/fillbutton.dart](../lib/presentation/widgets/fillbutton.dart) | Filled button | Not Started |
| Login With Button | [presentation/widgets/loginwith_button.dart](../lib/presentation/widgets/loginwith_button.dart) | Social login buttons | Not Started |
| Main Button | [presentation/widgets/main_button.dart](../lib/presentation/widgets/main_button.dart) | Primary button | Not Started |
| Other Widget | [presentation/widgets/other_widget.dart](../lib/presentation/widgets/other_widget.dart) | Miscellaneous widgets | Not Started |
| Size Box | [presentation/widgets/sizeboxx.dart](../lib/presentation/widgets/sizeboxx.dart) | Spacing widget | Not Started |
| Text Field | [presentation/widgets/textfield.dart](../lib/presentation/widgets/textfield.dart) | Custom text input | Not Started |

---

## 5. Payment Gateways
| Gateway | File | Purpose | Status |
|---------|------|---------|--------|
| Razorpay | [Logic/paymentGateway/razorpayy.dart](../lib/Logic/paymentGateway/razorpayy.dart) | Razorpay payment integration | Not Started |

---

## 6. Localization (Multi-Language)
| Component | File | Purpose | Status |
|-----------|------|---------|--------|
| App Localization | [language/localization/app_localization.dart](../lib/language/localization/app_localization.dart) | Localization strings | Not Started |
| App Localization Delegate | [language/localization/app_localization_delegate.dart](../lib/language/localization/app_localization_delegate.dart) | Localization delegate | Not Started |
| App Localization Setup | [language/localization/app_localization_setup.dart](../lib/language/localization/app_localization_setup.dart) | Localization initialization | Not Started |
| Language String | [language/localization/language_string.dart](../lib/language/localization/language_string.dart) | Language string constants | Not Started |
| Language Files | [../lang/](../lang/) | JSON files for supported languages (en, ar, hi, etc.) | Not Started |

---

## 7. Miscellaneous
| Component | File | Purpose | Status |
|-----------|------|---------|--------|
| Emoji Code | [EMOJICODE.dart](../lib/EMOJICODE.dart) | Emoji constants | Not Started |
| Extra App Screen | [extra_app_screen.dart](../lib/extra_app_screen.dart) | Extra screen | Not Started |
| Firebase Access Token | [firebase_accesstoken.dart](../lib/firebase_accesstoken.dart) | Firebase token handling | Not Started |
| Firebase Options | [firebase_options.dart](../lib/firebase_options.dart) | Firebase config for multiple platforms | Not Started |
| Extra OTP Code | [extra_otp_code/](../lib/extra_otp_code/) | OTP/verification models | Not Started |

---

## 8. Assets
| Asset Type | Location | Purpose |
|------------|----------|---------|
| Images | [assets/Image/](../assets/Image/) | App images, logos, onboarding |
| Icons | [assets/icons/](../assets/icons/) | SVG/PNG icons |
| Fonts | [assets/fonts/](../assets/fonts/) | Satoshi custom fonts |
| Lottie | [assets/lottie/](../assets/lottie/) | Lottie animations |
