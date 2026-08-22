import 'package:dating/Logic/cubits/onBording_cubit/onbording_cubit.dart';
import 'package:dating/Logic/cubits/onBording_cubit/onbording_state.dart';
import 'package:dating/presentation/screens/BottomNavBar/home_screen.dart';
import 'package:dating/presentation/screens/splash_bording/creat_steps.dart';
import 'package:dating/presentation/screens/splash_bording/onBordingProvider/onbording_provider.dart';
import 'package:dating/presentation/screens/pwa/core_pwa_home_screen.dart';
import 'package:dating/presentation/widgets/main_button.dart';
import 'package:dating/presentation/widgets/other_widget.dart';
import 'package:dating/presentation/widgets/sizeboxx.dart';
import 'package:dating/presentation/widgets/textfield.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';
import '../../../Logic/cubits/auth_cubit/auth_cubit.dart';
import '../../../Logic/cubits/auth_cubit/auth_state.dart';
import '../../../core/ui.dart';
import '../../../language/localization/app_localization.dart';
import '../../widgets/loginwith_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String loginRoute = "/loginScreen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late OnBordingProvider onBordingProvider;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<OnbordingCubit>(context).smstypeapi(context);
    onBordingProvider = Provider.of<OnBordingProvider>(context,listen: false);
    onBordingProvider.mobileNumber.text = '';
  }


  late OnbordingCubit onbordingCubit;


  int? otpvarable;

  @override
  Widget build(BuildContext context) {
    onBordingProvider = Provider.of<OnBordingProvider>(context);
    onbordingCubit = Provider.of<OnbordingCubit>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BackButtons(),
                      ],
                    ),
                    const SizBoxH(size: 0.04),
                    Text(
                      AppLocalizations.of(context)?.translate("Sign in") ?? "Sign in",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizBoxH(size: 0.01),
                    Text(
                      AppLocalizations.of(context)?.translate("Welcome back! Please enter your details.") ?? "Welcome back! Please enter your details.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizBoxH(size: 0.04),
                    TextFieldPro(
                        textalingn: TextAlign.start,
                        prefixIconIconPath: "assets/icons/envelope.svg",
                        controller: onBordingProvider.emailLogin,
                        hintText: AppLocalizations.of(context)?.translate("Email or MobileNumber") ?? "Email or MobileNumber"
                    ),
                    const SizBoxH(size: 0.02),
                    TextFieldPro(
                        surfixOntap: () {
                          onBordingProvider.updatebloginPass();
                        },
                        obscureText: onBordingProvider.loginpassObs,
                        textalingn: TextAlign.start,
                        prefixIconIconPath: "assets/icons/unlock.svg",
                        suffixIconPath: onBordingProvider.loginpassObs
                            ? "assets/icons/eye-slash.svg"
                            : "assets/icons/eye.svg",
                        controller: onBordingProvider.passwordLogin,
                        hintText: AppLocalizations.of(context)?.translate("Password") ?? "Password"
                    ),
                    const SizBoxH(size: 0.02),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: AppLocalizations.of(context)?.translate("Forgot password? ") ?? "Forgot password? ",
                          recognizer: TapGestureRecognizer()..onTap = () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              context: context, builder: (context) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)?.translate("Enter Number") ?? "Enter Number",
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 10,),
                                      IntlPhoneField(
                                        initialCountryCode: "IN",
                                        keyboardType: TextInputType.number,
                                        cursorColor: Colors.black,
                                        showCountryFlag: false,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        disableLengthCheck: true,
                                        controller: onBordingProvider.mobileNumber,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,

                                        dropdownIcon: const Icon(
                                          Icons.arrow_drop_down,
                                        ),
                                        dropdownTextStyle: Theme.of(context).textTheme.bodyMedium,
                                        style: Theme.of(context).textTheme.bodyMedium!,
                                        onCountryChanged: (value) {
                                          onBordingProvider.ccode = onBordingProvider.updateVeriable(value.dialCode);
                                        },
                                        onChanged: (value) {
                                          onBordingProvider.updateNameFiled(controller: onBordingProvider.mobileNumber, value: value.number);
                                        },
                                        decoration: InputDecoration(
                                          helperText: null,
                                          hintText: AppLocalizations.of(context)?.translate("Mobile Number") ?? "Mobile Number",
                                          hintStyle: Theme.of(context).textTheme.bodyMedium,
                                          filled: true,
                                          fillColor: Theme.of(context).cardColor,
                                          focusedBorder: OutlineInputBorder(

                                            borderRadius: BorderRadius.circular(15),
                                            borderSide: BorderSide(
                                              color: AppColors.appColor,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context).dividerTheme.color!,
                                            ),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                                        invalidNumberMessage: AppLocalizations.of(context)?.translate("Please enter your mobile number") ?? "Please enter your mobile number",
                                      ),
                                      const SizedBox(height: 10,),
                                      Row(
                                        children: [
                                          Expanded(child: MainButton(title: AppLocalizations.of(context)?.translate("Continue") ?? "Continue",onTap: () {

                                            if(onbordingCubit.smaTypeApiModel?.otpAuth == "Yes"){
                                              print("otp yes condition");

                                              // if(onbordingCubit.smaTypeApiModel?.smsType == "Firebase"){
                                              //
                                              //   if(onBordingProvider.mobileNumber.text.isEmpty){
                                              //     Fluttertoast.showToast(msg: "Please Enter Your Mobile Number");
                                              //   }else{
                                              //     BlocProvider.of<OnbordingCubit>(context).mobileCheckApi(number: onBordingProvider.mobileNumber.text, ccode: onBordingProvider.ccode).then((value) {
                                              //       if (value == "false") {
                                              //         BlocProvider.of<OnbordingCubit>(context).sendOtpFunction(number: "+${onBordingProvider.ccode} ${onBordingProvider.mobileNumber.text}", context: context,isForgot: true);
                                              //       }else{
                                              //         Navigator.pop(context);
                                              //         Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Number Not Exist") ?? "Number Not Exist");
                                              //       }
                                              //     });
                                              //   }
                                              //
                                              // }

                                              if (onbordingCubit.smaTypeApiModel?.smsType == "Msg91") {


                                                if(onBordingProvider.mobileNumber.text.isEmpty){
                                                  Fluttertoast.showToast(msg: "Please Enter Your Mobile Number");
                                                }else{

                                                  // onbordingCubit.msgotpapi(mobile: onBordingProvider.ccode + onBordingProvider.mobileNumber.text, context: context).then((value) {
                                                  onbordingCubit.msgotpapi(mobile: "+${onBordingProvider.ccode + onBordingProvider.mobileNumber.text}", context: context).then((value) {
                                                    showModalBottomSheet(
                                                        context: context,
                                                        isDismissible: false,
                                                        isScrollControlled: true,
                                                        builder: (BuildContext context) {
                                                          return Padding(
                                                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                            child: Container(
                                                              decoration: const BoxDecoration(
                                                                borderRadius: BorderRadius.vertical(
                                                                  top: Radius.circular(12),
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(15),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Text("Awesome", style: Theme.of(context).textTheme.headlineSmall),
                                                                    const SizedBox(height: 5),
                                                                    RichText(text: TextSpan(children: [
                                                                      TextSpan(text: AppLocalizations.of(context)?.translate("We have sent the OTP to") ?? "We have sent the OTP to",style: Theme.of(context).textTheme.bodyMedium),
                                                                      TextSpan(text: " +${onBordingProvider.ccode} ${onBordingProvider.mobileNumber.text}",style: Theme.of(context).textTheme.bodyMedium),
                                                                    ])),
                                                                    const SizedBox(height: 10),

                                                                    OTPTextField(
                                                                      length: 6,
                                                                      width: MediaQuery.of(context).size.width,
                                                                      fieldWidth: 45,
                                                                      keyboardType: TextInputType.number,
                                                                      outlineBorderRadius: 8,
                                                                      style: Theme.of(context).textTheme.headlineSmall!,
                                                                      textFieldAlignment: MainAxisAlignment.spaceAround,
                                                                      fieldStyle: FieldStyle.box,
                                                                      otpFieldStyle: OtpFieldStyle(borderColor: Theme.of(context).dividerTheme.color!,errorBorderColor: Theme.of(context).dividerTheme.color!,focusBorderColor: AppColors.appColor,enabledBorderColor: Theme.of(context).dividerTheme.color!,disabledBorderColor: Theme.of(context).dividerTheme.color!,backgroundColor: Theme.of(context).cardColor),
                                                                      onChanged: (value) {
                                                                        onBordingProvider.otp = value;
                                                                        otpvarable = int.parse(onBordingProvider.otp);
                                                                        print("77777:--- ${otpvarable}");
                                                                        setState(() {

                                                                        });
                                                                      },
                                                                    ),

                                                                    const SizedBox(height: 20),
                                                                    MainButton(
                                                                      title: AppLocalizations.of(context)?.translate("Continue") ?? "Continue",
                                                                      onTap: () async {
                                                                        if (onbordingCubit.msgApiModel.otp == otpvarable) {
                                                                          Navigator.pop(context);
                                                                          onBordingProvider.newPassWord(context,onBordingProvider.mobileNumber.text,onBordingProvider.ccode);
                                                                        }
                                                                        else {
                                                                          Fluttertoast.showToast(msg: "opt not valide");
                                                                        }
                                                                      },

                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  },);

                                                }

                                              }

                                              else if (onbordingCubit.smaTypeApiModel?.smsType == "Twilio") {
                                                print("******* Twilio *******");

                                                BlocProvider.of<OnbordingCubit>(context).mobileCheckApi(number: onBordingProvider.mobileNumber.text, ccode: onBordingProvider.ccode).then((value) {
                                                  if (value == "true") {

                                                    onbordingCubit.twilyootp(mobile: "+${onBordingProvider.ccode + onBordingProvider.mobileNumber.text}", context: context).then((value) {
                                                      showModalBottomSheet(
                                                          context: context,
                                                          isDismissible: false,
                                                          isScrollControlled: true,
                                                          builder: (BuildContext context) {
                                                            return Padding(
                                                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                              child: Container(
                                                                decoration: const BoxDecoration(
                                                                  borderRadius: BorderRadius.vertical(
                                                                    top: Radius.circular(12),
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(15),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Text("Awesome", style: Theme.of(context).textTheme.headlineSmall),
                                                                      const SizedBox(height: 5),
                                                                      RichText(text: TextSpan(children: [
                                                                        // TextSpan(text: "We have sent the OTP to".tr,style: Theme.of(context).textTheme.bodyMedium),
                                                                        TextSpan(text: AppLocalizations.of(context)?.translate("We have sent the OTP to") ?? "We have sent the OTP to",style: Theme.of(context).textTheme.bodyMedium),
                                                                        TextSpan(text: " +${onBordingProvider.ccode} ${onBordingProvider.mobileNumber.text}",style: Theme.of(context).textTheme.bodyMedium),
                                                                      ])),
                                                                      const SizedBox(height: 10),

                                                                      OTPTextField(
                                                                        length: 6,
                                                                        width: MediaQuery.of(context).size.width,
                                                                        fieldWidth: 45,
                                                                        keyboardType: TextInputType.number,
                                                                        outlineBorderRadius: 8,
                                                                        style: Theme.of(context).textTheme.headlineSmall!,
                                                                        textFieldAlignment: MainAxisAlignment.spaceAround,
                                                                        fieldStyle: FieldStyle.box,
                                                                        otpFieldStyle: OtpFieldStyle(borderColor: Theme.of(context).dividerTheme.color!,errorBorderColor: Theme.of(context).dividerTheme.color!,focusBorderColor: AppColors.appColor,enabledBorderColor: Theme.of(context).dividerTheme.color!,disabledBorderColor: Theme.of(context).dividerTheme.color!,backgroundColor: Theme.of(context).cardColor),
                                                                        onChanged: (value) {
                                                                          onBordingProvider.otp = value;
                                                                          otpvarable = int.parse(onBordingProvider.otp);
                                                                          print("77777:--- ${otpvarable}");
                                                                          setState(() {

                                                                          });
                                                                        },
                                                                      ),

                                                                      const SizedBox(height: 20),
                                                                      MainButton(
                                                                        // title: "Continue".tr,
                                                                        title: AppLocalizations.of(context)?.translate("Continue") ?? "Continue",
                                                                        onTap: () async {

                                                                          if (onbordingCubit.twilioApiModel.otp == otpvarable) {

                                                                            Navigator.pop(context);
                                                                            onBordingProvider.newPassWord(context,onBordingProvider.mobileNumber.text,onBordingProvider.ccode);

                                                                          }
                                                                          else {
                                                                            Fluttertoast.showToast(msg: "opt not valide");
                                                                          }

                                                                        },

                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          });
                                                    },);

                                                  }
                                                });


                                              }

                                              else {
                                                Fluttertoast.showToast(msg: "No Service");
                                              }

                                            }else{
                                              print("otp No condition");

                                              onBordingProvider.newPassWord(context,onBordingProvider.mobileNumber.text,onBordingProvider.ccode);

                                            }


                                          },))

                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },);
                          },
                          style: Theme.of(context).textTheme.bodySmall!),
                      TextSpan(
                          text: AppLocalizations.of(context)?.translate("Reset it") ?? "Reset it",
                          recognizer: TapGestureRecognizer()..onTap = () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              context: context, builder: (context) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)?.translate("Enter Number") ?? "Enter Number",
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 10,),
                                      IntlPhoneField(
                                        initialCountryCode: "IN",
                                        keyboardType: TextInputType.number,
                                        cursorColor: Colors.black,
                                        showCountryFlag: false,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        disableLengthCheck: true,
                                        controller: onBordingProvider.mobileNumber,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,

                                        dropdownIcon: const Icon(
                                          Icons.arrow_drop_down,
                                        ),
                                        dropdownTextStyle: Theme.of(context).textTheme.bodyMedium,
                                        style: Theme.of(context).textTheme.bodyMedium!,
                                        onCountryChanged: (value) {
                                          onBordingProvider.ccode = onBordingProvider.updateVeriable(value.dialCode);
                                        },
                                        onChanged: (value) {
                                          onBordingProvider.updateNameFiled(controller: onBordingProvider.mobileNumber, value: value.number);
                                        },
                                        decoration: InputDecoration(
                                          helperText: null,
                                          hintText: AppLocalizations.of(context)?.translate("Mobile Number") ?? "Mobile Number",
                                          hintStyle: Theme.of(context).textTheme.bodyMedium,
                                          filled: true,
                                          fillColor: Theme.of(context).cardColor,
                                          focusedBorder: OutlineInputBorder(

                                            borderRadius: BorderRadius.circular(15),
                                            borderSide: BorderSide(
                                              color: AppColors.appColor,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(context).dividerTheme.color!,
                                            ),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                                        invalidNumberMessage: AppLocalizations.of(context)?.translate("Please enter your mobile number") ?? "Please enter your mobile number",
                                      ),
                                      const SizedBox(height: 10,),
                                      Row(
                                        children: [
                                          Expanded(child: MainButton(title: AppLocalizations.of(context)?.translate("Continue") ?? "Continue",onTap: () {

                                            if(onbordingCubit.smaTypeApiModel?.otpAuth == "Yes"){
                                              print("otp yes condition");

                                              // if(onbordingCubit.smaTypeApiModel?.smsType == "Firebase"){
                                              //
                                              //   if(onBordingProvider.mobileNumber.text.isEmpty){
                                              //     Fluttertoast.showToast(msg: "Please Enter Your Mobile Number");
                                              //   }else{
                                              //     BlocProvider.of<OnbordingCubit>(context).mobileCheckApi(number: onBordingProvider.mobileNumber.text, ccode: onBordingProvider.ccode).then((value) {
                                              //       if (value == "false") {
                                              //         BlocProvider.of<OnbordingCubit>(context).sendOtpFunction(number: "+${onBordingProvider.ccode} ${onBordingProvider.mobileNumber.text}", context: context,isForgot: true);
                                              //       }else{
                                              //         Navigator.pop(context);
                                              //         Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Number Not Exist") ?? "Number Not Exist");
                                              //       }
                                              //     });
                                              //   }
                                              //
                                              // }

                                              if (onbordingCubit.smaTypeApiModel?.smsType == "Msg91") {


                                                if(onBordingProvider.mobileNumber.text.isEmpty){
                                                  Fluttertoast.showToast(msg: "Please Enter Your Mobile Number");
                                                }else{

                                                  onbordingCubit.msgotpapi(mobile: "+${onBordingProvider.ccode + onBordingProvider.mobileNumber.text}", context: context).then((value) {
                                                    showModalBottomSheet(
                                                        context: context,
                                                        isDismissible: false,
                                                        isScrollControlled: true,
                                                        builder: (BuildContext context) {
                                                          return Padding(
                                                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                            child: Container(
                                                              decoration: const BoxDecoration(
                                                                borderRadius: BorderRadius.vertical(
                                                                  top: Radius.circular(12),
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(15),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Text("Awesome", style: Theme.of(context).textTheme.headlineSmall),
                                                                    const SizedBox(height: 5),
                                                                    RichText(text: TextSpan(children: [
                                                                      TextSpan(text: AppLocalizations.of(context)?.translate("We have sent the OTP to") ?? "We have sent the OTP to",style: Theme.of(context).textTheme.bodyMedium),
                                                                      TextSpan(text: " +${onBordingProvider.ccode} ${onBordingProvider.mobileNumber.text}",style: Theme.of(context).textTheme.bodyMedium),
                                                                    ])),
                                                                    const SizedBox(height: 10),

                                                                    OTPTextField(
                                                                      length: 6,
                                                                      width: MediaQuery.of(context).size.width,
                                                                      fieldWidth: 45,
                                                                      keyboardType: TextInputType.number,
                                                                      outlineBorderRadius: 8,
                                                                      style: Theme.of(context).textTheme.headlineSmall!,
                                                                      textFieldAlignment: MainAxisAlignment.spaceAround,
                                                                      fieldStyle: FieldStyle.box,
                                                                      otpFieldStyle: OtpFieldStyle(borderColor: Theme.of(context).dividerTheme.color!,errorBorderColor: Theme.of(context).dividerTheme.color!,focusBorderColor: AppColors.appColor,enabledBorderColor: Theme.of(context).dividerTheme.color!,disabledBorderColor: Theme.of(context).dividerTheme.color!,backgroundColor: Theme.of(context).cardColor),
                                                                      onChanged: (value) {
                                                                        onBordingProvider.otp = value;
                                                                        otpvarable = int.parse(onBordingProvider.otp);
                                                                        print("77777:--- ${otpvarable}");
                                                                        setState(() {

                                                                        });
                                                                      },
                                                                    ),

                                                                    const SizedBox(height: 20),
                                                                    MainButton(
                                                                      title: AppLocalizations.of(context)?.translate("Continue") ?? "Continue",
                                                                      onTap: () async {


                                                                        if (onbordingCubit.msgApiModel.otp == otpvarable) {
                                                                          Navigator.pop(context);
                                                                          onBordingProvider.newPassWord(context,onBordingProvider.mobileNumber.text,onBordingProvider.ccode);
                                                                        }
                                                                        else {
                                                                          Fluttertoast.showToast(msg: "opt not valide");
                                                                        }


                                                                      },

                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  },);

                                                }

                                              }

                                              else if (onbordingCubit.smaTypeApiModel?.smsType == "Twilio") {
                                                print("******* Twilio *******");

                                                BlocProvider.of<OnbordingCubit>(context).mobileCheckApi(number: onBordingProvider.mobileNumber.text, ccode: onBordingProvider.ccode).then((value) {
                                                  if (value == "true") {

                                                    onbordingCubit.twilyootp(mobile: "+${onBordingProvider.ccode + onBordingProvider.mobileNumber.text}", context: context).then((value) {
                                                      showModalBottomSheet(
                                                          context: context,
                                                          isDismissible: false,
                                                          isScrollControlled: true,
                                                          builder: (BuildContext context) {
                                                            return Padding(
                                                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                              child: Container(
                                                                decoration: const BoxDecoration(
                                                                  borderRadius: BorderRadius.vertical(
                                                                    top: Radius.circular(12),
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(15),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Text("Awesome", style: Theme.of(context).textTheme.headlineSmall),
                                                                      const SizedBox(height: 5),
                                                                      RichText(text: TextSpan(children: [
                                                                        TextSpan(text: AppLocalizations.of(context)?.translate("We have sent the OTP to") ?? "We have sent the OTP to",style: Theme.of(context).textTheme.bodyMedium),
                                                                        TextSpan(text: " +${onBordingProvider.ccode} ${onBordingProvider.mobileNumber.text}",style: Theme.of(context).textTheme.bodyMedium),
                                                                      ])),
                                                                      const SizedBox(height: 10),

                                                                      OTPTextField(
                                                                        length: 6,
                                                                        width: MediaQuery.of(context).size.width,
                                                                        fieldWidth: 45,
                                                                        keyboardType: TextInputType.number,
                                                                        outlineBorderRadius: 8,
                                                                        style: Theme.of(context).textTheme.headlineSmall!,
                                                                        textFieldAlignment: MainAxisAlignment.spaceAround,
                                                                        fieldStyle: FieldStyle.box,
                                                                        otpFieldStyle: OtpFieldStyle(borderColor: Theme.of(context).dividerTheme.color!,errorBorderColor: Theme.of(context).dividerTheme.color!,focusBorderColor: AppColors.appColor,enabledBorderColor: Theme.of(context).dividerTheme.color!,disabledBorderColor: Theme.of(context).dividerTheme.color!,backgroundColor: Theme.of(context).cardColor),
                                                                        onChanged: (value) {
                                                                          onBordingProvider.otp = value;
                                                                          otpvarable = int.parse(onBordingProvider.otp);
                                                                          print("77777:--- ${otpvarable}");
                                                                          setState(() {

                                                                          });
                                                                        },
                                                                      ),

                                                                      const SizedBox(height: 20),
                                                                      MainButton(
                                                                        title: AppLocalizations.of(context)?.translate("Continue") ?? "Continue",
                                                                        onTap: () async {




                                                                          if (onbordingCubit.twilioApiModel.otp == otpvarable) {
                                                                            Navigator.pop(context);
                                                                            onBordingProvider.newPassWord(context,onBordingProvider.mobileNumber.text,onBordingProvider.ccode);
                                                                          }
                                                                          else {
                                                                            Fluttertoast.showToast(msg: "opt not valide");
                                                                          }

                                                                        },

                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          });
                                                    },);

                                                  }
                                                });


                                              }

                                              else {
                                                Fluttertoast.showToast(msg: "No Service");
                                              }

                                            }else{
                                              print("otp No condition");

                                              onBordingProvider.newPassWord(context,onBordingProvider.mobileNumber.text,onBordingProvider.ccode);

                                            }

                                          },))

                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },);
                            },
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.appColor),
                      ),
                    ])),
                    const SizBoxH(size: 0.04),
                    MainButton(
                      title: AppLocalizations.of(context)?.translate("Sign In") ?? "Sign In",
                      titleColor: Colors.white,
                      bgColor: AppColors.appColor,
                      onTap: () {

                        if(onBordingProvider.emailLogin.text.isEmpty || onBordingProvider.passwordLogin.text.isEmpty){
                          Fluttertoast.showToast(msg: "Please Enter All Input");
                        }else {
                          BlocProvider.of<OnbordingCubit>(context).loginWithEmailPass(context: context, mobile: onBordingProvider.emailLogin.text, password: onBordingProvider.passwordLogin.text, ccode: "+91");
                        }

                        },
                    ),
                    const SizBoxH(size: 0.04),
                    // onbordingCubit.smaTypeApiModel?.socialLoginEnabled == "No" ? const SizedBox() :    LoginWithButton(
                    //     bgColor: Colors.transparent,
                    //     title: AppLocalizations.of(context)?.translate("Connect with Google") ?? "Connect with Google",
                    //     iconpath: "assets/icons/google.svg",textColor: Theme.of(context).indicatorColor,
                    //     onTap: () {
                    //       BlocProvider.of<AuthCubit>(context).signInWithGoogle(context);
                    //     }),
                    // const SizBoxH(size: 0.018),
                    // onbordingCubit.smaTypeApiModel?.socialLoginEnabled == "No" ? const SizedBox() :  LoginWithButton(
                    //   bgColor: Colors.transparent,
                    //   // title: "Connect with Facebook".tr,
                    //   title: AppLocalizations.of(context)?.translate("Connect with Facebook") ?? "Connect with Facebook",
                    //   iconpath: "assets/icons/facebook.svg",
                    //     textColor: Theme.of(context).indicatorColor,
                    //   onTap: () {
                    //     BlocProvider.of<AuthCubit>(context)
                    //         .signInWithFacebook(context);
                    //   },
                    // ),
                    // const SizBoxH(size: 0.018),
                    // onbordingCubit.smaTypeApiModel?.socialLoginEnabled == "No" ? SizedBox() :  LoginWithButton(
                    //   bgColor: Colors.transparent,
                    //   // title: "Connect with Apple".tr,
                    //   title: AppLocalizations.of(context)?.translate("Connect with Apple") ?? "Connect with Apple",
                    //   iconpath: "assets/icons/applelogo.svg",
                    //   textColor: Theme.of(context).indicatorColor,
                    //   onTap: () {
                    //     BlocProvider.of<AuthCubit>(context).signInWithApple(context);
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
            BlocConsumer<OnbordingCubit, OnbordingState>(
                listener: (context, state) {
              if (state is ErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
              }
              if (state is CompletSteps) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  HomeScreen.homeScrennRoute,
                  (route) => false,
                );
              }
            }, builder: (context, state) {
              if (state is LoadingState) {
                return Center(child: CircularProgressIndicator(color: AppColors.appColor));
              } else {
                return const SizedBox();
              }
            }),
            BlocConsumer<AuthCubit, AuthStates>(
              listener: (context, state) {

              if (state is AuthErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage)));
              }

              if (state is AuthLoggedInState) {
                Navigator.pushNamed(context, CreatSteps.creatStepsRoute);
                onBordingProvider.setDataInFildes(state.firebaseuser);
              }

              if (state is AuthUserHomeState) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  HomeScreen.homeScrennRoute,
                  (route) => false,
                );
              }

              },
              builder: (context, state) {

              if(state is AuthLoading) {

                return Center(child: CircularProgressIndicator(color: AppColors.appColor));

              } else {

                return const SizedBox();

              }
            })
          ],
        ),
      ),
    );
  }
}
