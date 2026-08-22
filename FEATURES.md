# GoMeet Flutter Application Features

This document outlines the key features and functionalities of the GoMeet Flutter application, along with the corresponding files and technical details.

## 1. Authentication & Onboarding
User registration and login flow.
- **Functionality**:
    - Login with Email/Password.
    - Social Login (Google/Facebook/Apple).
    - OTP Verification.
    - Password Recovery.
    - User Onboarding (Intro screens).
    - Profile Creation Steps (Gender, Name, DOB, etc.).
- **Key Files**:
    - `lib/presentation/screens/auth/login_screen.dart`
    - `lib/presentation/screens/splash_bording/auth_screen.dart`
    - `lib/presentation/screens/splash_bording/creat_steps.dart`
    - `lib/presentation/screens/splash_bording/onbording_screens.dart`
    - `lib/Logic/cubits/auth_cubit/` (State Management)
    - `lib/extra_otp_code/` (OTP Handling)

## 2. Home & Matching (Dating Core)
The core functionality of swiping and matching with other users.
- **Functionality**:
    - Swipe Left/Right mechanism (Like/Pass).
    - View User Cards with details.
    - Match Logic.
    - Browse Users.
- **Key Files**:
    - `lib/presentation/screens/BottomNavBar/home_screen.dart`
    - `lib/presentation/screens/BottomNavBar/match/browes.dart`
    - `lib/Logic/cubits/Home_cubit/`
    - `lib/Logic/cubits/match_cubit/`

## 3. Real-time Communication
Chat and calling features powered by Firebase and Agora.
- **Functionality**:
    - Real-time Text Chat (Firebase Firestore).
    - Video Calling (Agora SDK).
    - Audio Calling.
    - Push Notifications for messages and calls.
- **Key Files**:
    - `lib/presentation/screens/BottomNavBar/chats.dart`
    - `lib/presentation/firebase/chat_page.dart`
    - `lib/presentation/firebase/videocall_screen.dart` (Agora integration)
    - `lib/presentation/screens/AudioCall/audiocall_screen.dart`
    - `lib/presentation/firebase/chat_service.dart`

## 4. Profile Management
Users can manage their personal information and preferences.
- **Functionality**:
    - View Own Profile.
    - Edit Profile (Photos, Bio, Interests).
    - Privacy Settings.
    - Block List.
    - View Likes and Matches.
- **Key Files**:
    - `lib/presentation/screens/other/profileScreen/profile_page.dart`
    - `lib/presentation/screens/other/editProfile/editprofile.dart`
    - `lib/presentation/screens/other/likeMatch/like_match.dart`
    - `lib/Logic/cubits/editProfile_cubit/`

## 5. Premium & Subscription
Monetization features.
- **Functionality**:
    - View Premium Plans.
    - Subscribe to Plans.
    - Payment Gateway Integration (Stripe, PayPal, Razorpay, Paystack).
- **Key Files**:
    - `lib/presentation/screens/other/premium/premium.dart`
    - `lib/presentation/screens/other/premium/plandetials.dart`
    - `lib/payment/` (Payment implementations)
    - `lib/Logic/paymentGateway/razorpayy.dart`
    - `lib/Logic/cubits/premium_cubit/`

## 6. Wallet & Coins
Virtual currency system.
- **Functionality**:
    - In-app Wallet.
    - Purchase Coins.
    - Transaction History.
    - Send Gifts using coins.
- **Key Files**:
    - `lib/wallete_code/wallete_screen.dart`
    - `lib/by_coin_screen/coin_screen.dart`
    - `lib/by_coin_screen/mygift.dart`

## 7. Discovery & Location
Finding users nearby.
- **Functionality**:
    - Map View.
    - Location-based filtering.
- **Key Files**:
    - `lib/presentation/screens/BottomNavBar/mapscreen.dart`
    - `lib/data/models/mapmodel.dart`

## 8. Miscellaneous Features
- **Localization**: Multi-language support (`lib/language/`).
- **Push Notifications**: Firebase Cloud Messaging (`lib/core/push_notification_function.dart`).
- **Theme**: Light/Dark mode (`lib/Logic/cubits/litedark/`).
- **Refer & Earn**: Referral system (`lib/by_coin_screen/refer_and_earn_screen.dart`).
- **Google AdMob**: Ad integration (`lib/core/google_ads.dart`).

## Technical Stack
- **Framework**: Flutter
- **State Management**: BLoC / Cubit & Provider
- **Backend**: Firebase (Auth, Firestore, Storage) & Custom API
- **Video/Audio**: Agora RTC
- **Maps**: Google Maps
