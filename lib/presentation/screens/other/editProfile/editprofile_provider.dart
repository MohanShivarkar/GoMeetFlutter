import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:dating/core/ui.dart';
import 'package:dating/data/models/relationgoalmodel.dart';
import 'package:dating/data/models/religionmodel.dart';
import 'package:dating/data/models/usermodel.dart';
import 'package:dating/presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:image_picker/image_picker.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';
import '../../../../Logic/cubits/editProfile_cubit/editprofile_cubit.dart';
import '../../../../data/models/getinterest_model.dart';
import '../../../../data/models/languagemodel.dart';
import '../../../../language/localization/app_localization.dart';
import '../../../widgets/main_button.dart';

class EditProfileProvider extends ChangeNotifier {
  final bio = TextEditingController();
  final name = TextEditingController();
  final email = TextEditingController();
  final mobileNumber = TextEditingController();
  final password = TextEditingController();
  final hobieSearchContoller = TextEditingController();
  final languageSearchContoller = TextEditingController();
  final religionSearchContoller = TextEditingController();
  final heightcontrooler = TextEditingController();

  List<Interestlist>? interest;
  List<Languagelist>? language;
  List<Religionlist>? religion;
  List<Goallist>? relationShip;

  List searchForHobie = [];
  List searchForLanguage = [];
  List searchForReligion = [];
  List networkOldImage = [];
  List<XFile> newImage = [];
  List<Uint8List> newImageBytes = [];

  int selectReligion = -1;
  int selectRelationShip = -1;

  List interestList = [];
  List languageList = [];


  DateTime? bdatePicker;

  updatebdate(DateTime date) {
    bdatePicker = date;
    notifyListeners();
  }


  int gender = -1;
  int searchPreference = -1;

  double radius = 0;
  updateRadius(double value) {
    radius = value;
    notifyListeners();
  }

  updateMaleFemale(int value) {
    gender = value;
    notifyListeners();
  }

  updateSearchPreference(int value) {
    searchPreference = value;
    notifyListeners();
  }

  updateVeriable(value2) {
    notifyListeners();
    return value2;
  }
  String ccode = "91";
  List manWoman = ["Man", "Woman", "Other"];
  List searchPref = ["Man", "Woman", "Both"];

  String maleFemaleOther(int value) {
    switch (value) {
      case 0:
        return "MALE";
      case 1:
        return "FEMALE";
      case 2:
        return "OTHER";
      default:
        return "";
    }
  }

  String maleFemaleBoth(int value) {
    switch (value) {
      case 0:
        return "MALE";
      case 1:
        return "FEMALE";
      case 2:
        return "BOTH";
      default:
        return "";
    }
  }

  final ImagePicker picker = ImagePicker();

  valuInReligion(List<Religionlist> value) {
    religion = value;
    notifyListeners();
  }

  valuInIntrest(List<Interestlist> value) {
    interest = value;
    notifyListeners();
  }

  valuInrelationShip(List<Goallist> value) {
    relationShip = value;
    notifyListeners();
  }

  valuInLanguage(List<Languagelist> value) {
    language = value;
    notifyListeners();
  }

  searchLanguage(s) {
    searchForLanguage = [];
    for (int i = 0; i < language!.length; i++) {
      if (language![i]
          .title
          .toString()
          .toLowerCase()
          .contains(s.toLowerCase())) {
        final ids = language!.map<String>((e) => e.id!).toSet();

        language!.retainWhere((x) {
          return ids.remove(x.id);
        });

        searchForLanguage.add(i);
        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }

  searchHobie(s) {
    searchForHobie = [];
    for (int i = 0; i < interest!.length; i++) {
      if (interest![i]
          .title
          .toString()
          .toLowerCase()
          .contains(s.toLowerCase())) {
        final ids = interest!.map<String>((e) => e.id!).toSet();

        interest!.retainWhere((x) {
          return ids.remove(x.id);
        });

        searchForHobie.add(i);
        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }


  bool obsText = true;
  updatebloginPass() {
    obsText = !obsText;
    notifyListeners();
  }


  String vericitionId = "";
  String otp = "";
  ConfirmationResult? webConfirmationResult;

  otpBottomSheet(context) {
    return showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              // height: 100,
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
                    Text(AppLocalizations.of(context)?.translate("Awesome") ?? "Awesome", style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 5),
                    Text(
                      "We have sent the OTP to +$ccode ${mobileNumber.text}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
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
                      otpFieldStyle: OtpFieldStyle(borderColor: Theme.of(context).indicatorColor,errorBorderColor: Theme.of(context).indicatorColor,focusBorderColor: AppColors.appColor,enabledBorderColor: Theme.of(context).indicatorColor,disabledBorderColor: Theme.of(context).indicatorColor,backgroundColor: Theme.of(context).cardColor),
                      onChanged: (value) {
                        otp = value;
                        notifyListeners();
                      },
                    ),
                    const SizedBox(height: 20),
                    MainButton(
                      bgColor: AppColors.appColor,
                      title: AppLocalizations.of(context)?.translate("Continue") ?? "Continue",
                      onTap: () async {

                        try {
                          UserCredential value;
                          if (kIsWeb && webConfirmationResult != null) {
                            value = await webConfirmationResult!.confirm(otp);
                          } else {
                            PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: vericitionId, smsCode: otp);
                            value = await FirebaseAuth.instance.signInWithCredential(credential);
                          }
                          if (value.user != null) {
                            finalApiCall(context, true);
                          }
                        } catch (e) {
                          Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("OTP Invalid") ?? "OTP Invalid");
                        }

                      },
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  searchReligion(s) {
    searchForReligion = [];
    for (int i = 0; i < religion!.length; i++) {
      if (religion![i]
          .title
          .toString()
          .toLowerCase()
          .contains(s.toLowerCase())) {
        final ids = religion!.map<String>((e) => e.id!).toSet();

        religion!.retainWhere((x) {
          return ids.remove(x.id);
        });

        searchForReligion.add(i);

        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }

  updatereligion(int value) {
    selectReligion = value;
    notifyListeners();
  }



  updaterelationGoal(int value) {
    selectRelationShip = value;
    notifyListeners();
  }

  addInlanguage(value) {
    languageList.add(value);
    notifyListeners();
  }

  removeLanguage(value) {
    languageList.remove(value);
    notifyListeners();
  }

  addInHobi(value) {
    interestList.add(value);
    notifyListeners();
  }

  removeHobi(value) {
    interestList.remove(value);
    notifyListeners();
  }

  removeNetWorkImage(index) {
    networkOldImage.removeAt(index);
    notifyListeners();
  }

  removeNewImage(index) {
    if (index >= 0 && index < newImage.length) {
      newImage.removeAt(index);
    }
    if (index >= 0 && index < newImageBytes.length) {
      newImageBytes.removeAt(index);
    }
    notifyListeners();
  }

  addNewImage(vale) async {
    if (vale != null) {
      newImage.add(vale);
      try {
        Uint8List bytes = await (vale as XFile).readAsBytes();
        newImageBytes.add(bytes);
      } catch (e) {
        print("Error reading picked image bytes: $e");
      }
      notifyListeners();
    }
  }

  updateNameFiled({required TextEditingController controller, value}) {
    if (controller.text != value) {
      controller.text = value ?? "";
    }
  }

 Future dataTransfer(context)  async {
    UserModel userData = Provider.of<HomeProvider>(context,listen: false).userlocalData;
    networkOldImage.clear();
    languageList.clear();
    interestList.clear();
    newImage.clear();
    newImageBytes.clear();
    var u = userData.userLogin;
    if (u == null) return;
    name.text = u.name ?? "";
    bio.text = u.profileBio ?? "";
    email.text = u.email ?? "";
    bdatePicker = u.birthDate;
    languageList = (u.language != null && u.language!.isNotEmpty) ? u.language!.split(",") : [];
    interestList = (u.interest != null && u.interest!.isNotEmpty) ? u.interest!.split(",") : [];
    selectReligion = int.tryParse(u.religion ?? '1') ?? 1;
    selectRelationShip = int.tryParse(u.relationGoal ?? '1') ?? 1;
    networkOldImage = (u.otherPic != null && u.otherPic!.isNotEmpty) ? u.otherPic!.split("\$;") : [];
    gender = maleFemaleOtherIndex(u.gender ?? "MALE");
    searchPreference = maleFemaleBothIndex(u.searchPreference ?? "BOTH");
    mobileNumber.text = u.mobile ?? "";
    ccode = (u.ccode ?? "+91").replaceAll("+", "");
    password.text = u.password ?? "";
    radius = double.tryParse(u.radiusSearch ?? '50') ?? 50.0;
  }

  int maleFemaleBothIndex(String value) {
    switch (value) {
      case "MALE":
        return 0;
      case "FEMALE":
        return 1;
      case "BOTH":
        return 2;
      default:
        return 0;
    }
  }

  int maleFemaleOtherIndex(String value) {
    switch (value) {
      case "MALE":
        return 0;
      case "FEMALE":
        return 1;
      case "OTHER":
        return 2;
      default:
        return 0;
    }
  }

 Future finalApiCall(context,bool isOtp) async {
    BlocProvider.of<EditProfileCubit>(context).updateUserData(
      isOtp: isOtp,
        name: name.text,
        email: email.text,
        mobile: mobileNumber.text,
        ccode: ccode,
        password: password.text,
        bday: bdatePicker.toString().split(" ").first,
        searchPreference: maleFemaleBoth(searchPreference),
        rediusSearch: "$radius",
        gender: maleFemaleOther(gender),
        relationGoal: selectRelationShip.toString(),
        profileBio:bio.text,
        intrest: interestList.join(","),
        language: languageList.join(","),
        lat: (Provider.of<HomeProvider>(context, listen: false).lat ?? 19.0760).toString(),
        long: (Provider.of<HomeProvider>(context, listen: false).long ?? 72.8777).toString(),
        religon: selectReligion.toString(),
        imlist: networkOldImage.isEmpty ?  "0": networkOldImage.join("\$;"),
        uid: Provider.of<HomeProvider>(context, listen: false).uid.toString(),
        images: newImage,
        height: heightcontrooler.text,
        context: context
    );
  }

}
