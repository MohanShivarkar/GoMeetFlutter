import 'dart:io';
import 'package:dating/Logic/cubits/editProfile_cubit/editprofile_cubit.dart';
import 'package:dating/Logic/cubits/editProfile_cubit/editprofile_state.dart';
import 'package:dating/Logic/cubits/onBording_cubit/onbording_cubit.dart';
import 'package:dating/core/config.dart';
import 'package:dating/core/ui.dart';
import 'package:dating/data/models/relationgoalmodel.dart';
import 'package:dating/data/models/religionmodel.dart';
import 'package:dating/presentation/screens/other/editProfile/editprofile_provider.dart';
import 'package:dating/presentation/widgets/main_button.dart';
import 'package:dating/presentation/widgets/other_widget.dart';
import 'package:dating/presentation/widgets/sizeboxx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/getinterest_model.dart';
import '../../../../data/models/languagemodel.dart';
import '../../../../language/localization/app_localization.dart';
import '../../../widgets/textfield.dart';
import '../../BottomNavBar/homeProvider/homeprovier.dart';

class EditProfile extends StatefulWidget {
  static const String editProfileRoute = "/editProfile";
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<EditProfileCubit>(context).loadingState();
    initeStatee();
  }

  initeStatee(){
    editProvider = Provider.of<EditProfileProvider>(context,listen: false);
    editProvider.dataTransfer(context);
    BlocProvider.of<OnbordingCubit>(context).religionApi().then((value) {
      editProvider.valuInReligion(value.religionlist!);
      BlocProvider.of<OnbordingCubit>(context).relationGoalListApi().then((value) {
        editProvider.valuInrelationShip(value.goallist!);
        BlocProvider.of<OnbordingCubit>(context).languagelistApi().then((value) {
          editProvider.valuInLanguage(value.languagelist!);
          BlocProvider.of<OnbordingCubit>(context).getInterestApi().then((value) {
            editProvider.valuInIntrest(value.interestlist!);
            BlocProvider.of<EditProfileCubit>(context).compeltDataTransfer();
          });
        });
      });
    });

    print("++++:--  ${editProvider.ccode}");

  }


  late OnbordingCubit onbordingCubit;
  int? otpvarable;



  late EditProfileProvider editProvider;
  @override
  Widget build(BuildContext context) {
    editProvider = Provider.of<EditProfileProvider>(context);
    onbordingCubit = Provider.of<OnbordingCubit>(context);
    return Scaffold(

        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: const BackButtons(),
        ),

        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(15.0),
          child: MainButton(
            bgColor: AppColors.appColor,titleColor: Colors.white,
              title: AppLocalizations.of(context)?.translate("Update") ?? "Update",
              onTap: () {

              if(editProvider.mobileNumber.text.compareTo(Provider.of<HomeProvider>(context,listen: false).userlocalData.userLogin!.mobile!) != 0){


                if(onbordingCubit.smaTypeApiModel?.otpAuth == "Yes"){

                  // if(onbordingCubit.smaTypeApiModel?.smsType == "Firebase"){
                  //
                  //   BlocProvider.of<EditProfileCubit>(context).mobileCheckApi(number: editProvider.mobileNumber.text, ccode: editProvider.ccode).then((value) {
                  //     if (value == "true") {
                  //       BlocProvider.of<EditProfileCubit>(context).sendOtpFunction(number: "+${editProvider.ccode} ${editProvider.mobileNumber.text}", context: context);
                  //     }
                  //   });
                  //
                  // }

                   if (onbordingCubit.smaTypeApiModel?.smsType == "Msg91") {

                    BlocProvider.of<EditProfileCubit>(context).mobileCheckApi(number: editProvider.mobileNumber.text, ccode: editProvider.ccode).then((value) {
                      if (value == "true") {

                        onbordingCubit.msgotpapi(mobile: "+${editProvider.ccode +editProvider.mobileNumber.text}", context: context).then((value) {
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
                                          Text(AppLocalizations.of(context)?.translate("Awesome") ?? "Awesome", style: Theme.of(context).textTheme.headlineSmall),
                                          const SizedBox(height: 5),
                                          Text(
                                            "We have sent the OTP to +${editProvider.ccode} ${editProvider.mobileNumber.text}",
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
                                              editProvider.otp = value;
                                              otpvarable = int.parse(editProvider.otp);
                                              setState(() {});
                                            },
                                          ),
                                          const SizedBox(height: 20),
                                          MainButton(
                                            bgColor: AppColors.appColor,
                                            title: AppLocalizations.of(context)?.translate("Continue") ?? "Continue",
                                            onTap: () async {

                                              if (onbordingCubit.msgApiModel.otp == otpvarable) {
                                                editProvider.finalApiCall(context,true);
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
                  else if (onbordingCubit.smaTypeApiModel?.smsType == "Twilio") {
                    print("******* Twilio *******");


                    BlocProvider.of<EditProfileCubit>(context).mobileCheckApi(number: editProvider.mobileNumber.text, ccode: editProvider.ccode).then((value) {
                      if (value == "true") {

                        onbordingCubit.twilyootp(mobile: "+${editProvider.ccode +editProvider.mobileNumber.text}", context: context).then((value) {
                          showModalBottomSheet(
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
                                            "We have sent the OTP to +${editProvider.ccode} ${editProvider.mobileNumber.text}",
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
                                              editProvider.otp = value;
                                              otpvarable = int.parse(editProvider.otp);
                                              setState(() {});
                                            },
                                          ),
                                          const SizedBox(height: 20),
                                          MainButton(
                                            bgColor: AppColors.appColor,
                                            title: AppLocalizations.of(context)?.translate("Continue") ?? "Continue",
                                            onTap: () async {
                                              if (onbordingCubit.twilioApiModel.otp == otpvarable) {
                                                editProvider.finalApiCall(context,true);
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
                  print("final else condition");
                  editProvider.finalApiCall(context,false);
                }

              }else{
               editProvider.finalApiCall(context,false);
              }

              }),
        ),

        body: BlocConsumer<EditProfileCubit, EditProfileState>(
          listener: (context, state) {
            if (state is EditErrorState) {
              Fluttertoast.showToast(msg: state.error);
            }
          },
          builder: (context, state) {
            if (state is EditLoadingState) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.appColor),
              );
            } else {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                                runSpacing: 10,
                                spacing: 10,
                                runAlignment: WrapAlignment.center,
                                children: [
                                  for (int a = 0; a < editProvider.networkOldImage.length; a++)
                                    Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.topRight,
                                      children: [
                                        Container(
                                          height:
                                          MediaQuery.of(context).size.height /
                                              5,
                                          width: MediaQuery.of(context).size.width /
                                              3.5,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      "${Config.baseUrl}${editProvider.networkOldImage[a]}"),
                                                  fit: BoxFit.cover)),
                                        ),
                                        Positioned(
                                          top: -5,
                                          right: -5,
                                          child: InkWell(
                                            onTap: () {
                                              editProvider.removeNetWorkImage(a);
                                            },
                                            child: Container(
                                              height: 25,
                                              width: 25,
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.red),
                                              child: const Icon(
                                                Icons.close,
                                                size: 15,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  for (int a = 0; a < editProvider.newImage.length; a++)
                                    Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.topRight,
                                      children: [
                                        Container(
                                          height:
                                          MediaQuery.of(context).size.height /
                                              5,
                                          width: MediaQuery.of(context).size.width / 3.5,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                              image: DecorationImage(
                                                  image: FileImage(File(editProvider
                                                      .newImage[a].path
                                                      .toString())),
                                                  fit: BoxFit.cover)),
                                        ),
                                        Positioned(
                                          top: -5,
                                          right: -5,
                                          child: InkWell(
                                            onTap: () {
                                              editProvider.removeNewImage(a);
                                            },
                                            child: Container(
                                              height: 25,
                                              width: 25,
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.red),
                                              child: const Icon(
                                                Icons.close,
                                                size: 15,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  InkWell(
                                    onTap: () async {
                                      final XFile? image = await editProvider.picker
                                          .pickImage(source: ImageSource.gallery);
                                      editProvider.addNewImage(image);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Theme.of(context).dividerTheme.color!)),
                                      height:
                                      MediaQuery.of(context).size.height / 5,
                                      width:
                                      MediaQuery.of(context).size.width / 3.5,
                                      child: const Center(
                                        child: Icon(Icons.add),
                                      ),
                                    ),
                                  ),
                                ]
                            ),

                            const SizBoxH(size: 0.03),

                            commenTile(titile: AppLocalizations.of(context)?.translate("Nick name") ?? "Nick name", widget: TextFieldPro(
                              controller: editProvider.name,
                              hintText: AppLocalizations.of(context)?.translate("First Name") ?? "First Name",
                              onChangee: (e) {
                                editProvider.updateNameFiled(
                                    controller: editProvider.name, value: e);
                              },
                              textalingn: TextAlign.start,
                            ),traing: true),

                            commenTile(titile: AppLocalizations.of(context)?.translate("Email") ?? "Email", widget: TextFieldPro(
                              controller: editProvider.email,
                              hintText: AppLocalizations.of(context)?.translate("Email") ?? "Email",
                              onChangee: (e) {
                                editProvider.updateNameFiled(
                                    controller: editProvider.email, value: e);
                              },
                              textalingn: TextAlign.start,

                            ),traing: true),

                            commenTile(titile: AppLocalizations.of(context)?.translate("Mobile Number") ?? "Mobile Number", widget: TextFieldPro(
                              controller: editProvider.mobileNumber,
                              prefix: "+${editProvider.ccode} ",
                              hintText: AppLocalizations.of(context)?.translate("Mobile Number") ?? "Mobile Number",
                              onChangee: (e) {
                                editProvider.updateNameFiled(
                                    controller: editProvider.mobileNumber, value: e);
                              },
                              textalingn: TextAlign.start,

                            ),traing: true),


                            commenTile(titile: AppLocalizations.of(context)?.translate("Password") ?? "Password", widget: TextFieldPro(
                                surfixOntap: () {
                                  editProvider.updatebloginPass();
                                },
                                obscureText: editProvider.obsText,
                                textalingn: TextAlign.start,
                                prefixIconIconPath: "assets/icons/unlock.svg",
                                suffixIconPath: editProvider.obsText
                                    ? "assets/icons/eye-slash.svg"
                                    : "assets/icons/eye.svg",
                                controller: editProvider.password,
                                hintText: "Password"),traing: true),
                            Column(
                              children: [

                                Row(
                                  children: [

                                    Text(
                                      // "Radius".tr,
                                      AppLocalizations.of(context)?.translate("Radius") ?? "Radius",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                      ,
                                    ),

                                    const Spacer(),
                                    RichText(text: TextSpan(children: [
                                      TextSpan(text: editProvider.radius.toStringAsFixed(2),style: Theme.of(context).textTheme.bodySmall,),
                                      TextSpan(text: AppLocalizations.of(context)?.translate(" KM") ?? " KM",style: Theme.of(context).textTheme.bodySmall,),
                                    ])),

                                  ],
                                ),

                                const SizBoxH(size: 0.008),

                                SliderTheme(
                                  data: SliderThemeData(overlayShape:
                                  SliderComponentShape.noOverlay),
                                  child: Slider(
                                    value: editProvider.radius,
                                    max: 500,
                                    min: 10,
                                    activeColor: AppColors.appColor,
                                    inactiveColor: Theme.of(context).dividerTheme.color!,
                                    label: editProvider.radius.abs().toString(),
                                    onChanged: (double value) {
                                      editProvider.updateRadius(value);
                                    },
                                  ),
                                ),

                                const SizBoxH(size: 0.01),

                              ],
                            ),

                            commenTile(titile: AppLocalizations.of(context)?.translate("Birthdate") ?? "Birthdate", widget: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (c) {
                                            return Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: SizedBox(
                                                height: 200,
                                                child: CupertinoDatePicker(
                                                  mode: CupertinoDatePickerMode.date,
                                                  initialDateTime: DateTime(2000, 1, 1),
                                                  onDateTimeChanged: (DateTime newDateTime) {
                                                    editProvider.updatebdate(newDateTime);
                                                  },
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: Theme.of(context).cardColor,
                                          border: Border.all(color: Theme.of(context).dividerTheme.color!)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                            child: Text(
                                                "${editProvider.bdatePicker}" != "null"
                                                    ? editProvider.bdatePicker
                                                    .toString()
                                                    .split(" ")
                                                    .first
                                                    : "YYYY - MM - DD",
                                                style: Theme.of(context).textTheme.bodyMedium!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),traing: true),

                            commenTile(titile: AppLocalizations.of(context)?.translate("Bio") ?? "Bio", widget: TextFieldPro(
                              controller: editProvider.bio,
                              hintText: AppLocalizations.of(context)?.translate("Bio") ?? "Bio",
                              onChangee: (e) {
                                editProvider.updateNameFiled(
                                    controller: editProvider.bio, value: e);
                              },
                              textalingn: TextAlign.start,
                            ),traing: true),


                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)?.translate("Gender") ?? "Gender",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!,
                                    ),

                                  ],
                                ),
                                const SizBoxH(size: 0.008),
                                Wrap(
                                  runSpacing:13,
                                  children: [
                                    for (int a = 0;
                                    a < editProvider.manWoman.length;
                                    a++)
                                      Builder(builder: (context) {
                                        return  InkWell(
                                          onTap: () {
                                            editProvider.updateMaleFemale(a);
                                          },
                                          child: Container(
                                            margin:  const EdgeInsets.symmetric(horizontal: 5),
                                            padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8),
                                            decoration: BoxDecoration(
                                                color: editProvider.gender == a ? AppColors.appColor :  Theme.of(context).cardColor,
                                                borderRadius:
                                                BorderRadius.circular(40),
                                                border: Border.all(
                                                    color: editProvider.gender == a ? AppColors.appColor : Theme.of(context).dividerTheme.color!)),
                                            child: Text(editProvider.manWoman[a].toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                    color:
                                                    editProvider.gender == a ? AppColors.white : null)),
                                          ),
                                        );

                                      })
                                  ],
                                ),
                              ],
                            ),

                            const SizBoxH(size: 0.02),
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                    context: context,
                                    builder: (c) {
                                      editProvider =
                                          Provider.of<EditProfileProvider>(context,
                                              listen: false);
                                      return Consumer<EditProfileProvider>(
                                        builder: (context, bottomSheet, child) {
                                          return Container(
                                            height:
                                            MediaQuery.of(context).size.height /
                                                1.4,
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              borderRadius:
                                              BorderRadius.circular(16),
                                            ),
                                            child: Scaffold(
                                              bottomNavigationBar: MainButton(
                                                bgColor: AppColors.appColor,
                                                title: "Ok(${editProvider.interestList.length}/5)",
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              body: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    TextField(
                                                      controller: editProvider.hobieSearchContoller,
                                                      style: Theme.of(context).textTheme.bodySmall,
                                                      decoration: InputDecoration(
                                                        contentPadding:
                                                        const EdgeInsets.all(
                                                            10),
                                                        hintText: AppLocalizations.of(context)?.translate("Search..") ?? "Search..",
                                                        filled: true,
                                                        fillColor: Theme.of(context).cardColor,
                                                        hintStyle: Theme.of(context).textTheme.bodySmall,
                                                        prefixIcon: SizedBox(
                                                            height: 20,
                                                            width: 20,
                                                            child: Center(
                                                                child: SvgPicture.asset(
                                                                  "assets/icons/Search.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),))),
                                                        border: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Theme.of(context).dividerTheme.color!),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(12)),

                                                        enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Theme.of(context).dividerTheme.color!),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(12)),

                                                        disabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Theme.of(context).dividerTheme.color!),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(12)),

                                                        focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: AppColors.appColor),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(12)),
                                                      ),
                                                      onChanged: (c) {
                                                        editProvider.searchHobie(c);
                                                      },
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    editProvider
                                                        .hobieSearchContoller
                                                        .text
                                                        .isEmpty
                                                        ? Wrap(
                                                      alignment:
                                                      WrapAlignment.start,
                                                      spacing: 13,
                                                      runSpacing: 13,
                                                      children: [
                                                        for (int a = 0;
                                                        a < editProvider.interest!.length; a++)
                                                          Builder(builder:
                                                              (context) {
                                                            Interestlist data = editProvider.interest![a];
                                                            return InkWell(
                                                              onTap: () {
                                                                if (editProvider.interestList.contains(data.id) == true) {
                                                                  editProvider.removeHobi(data.id);
                                                                } else {
                                                                  if (editProvider.interestList.length < 5) {
                                                                    editProvider.addInHobi(data.id);
                                                                  }
                                                                }
                                                              },
                                                              child:
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                    12,
                                                                    vertical:
                                                                    8),
                                                                decoration: BoxDecoration(
                                                                    color: editProvider.interestList.contains(data.id) ? AppColors.appColor : Theme.of(context).cardColor,
                                                                    borderRadius:
                                                                    BorderRadius.circular(
                                                                        40),
                                                                    border: Border.all(
                                                                        color: editProvider.interestList.contains(data.id)
                                                                            ? Colors.transparent
                                                                            : Theme.of(context).dividerTheme.color!)),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                                  children: [
                                                                    Text(
                                                                        data.title
                                                                            .toString(),
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodySmall!
                                                                            .copyWith(color: editProvider.interestList.contains(data.id) ? AppColors.white : null)),
                                                                    const SizedBox(
                                                                      width:
                                                                      5,
                                                                    ),
                                                                    Image
                                                                        .network(
                                                                      "${Config.baseUrl}${data.img}",
                                                                      height:
                                                                      24,
                                                                      width:
                                                                      24,
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          })
                                                      ],
                                                    )
                                                        : editProvider
                                                        .searchForHobie
                                                        .isEmpty
                                                        ? const SizedBox()
                                                        : Wrap(
                                                      alignment:
                                                      WrapAlignment
                                                          .start,
                                                      spacing: 13,
                                                      runSpacing: 13,
                                                      children: [
                                                        for (int a = 0;
                                                        a <
                                                            editProvider
                                                                .searchForHobie
                                                                .length;
                                                        a++)
                                                          Builder(builder:
                                                              (context) {
                                                            var result =
                                                            editProvider
                                                                .searchForHobie[a];
                                                            Interestlist
                                                            data =
                                                            editProvider
                                                                .interest![
                                                            result];
                                                            return InkWell(
                                                              onTap: () {
                                                                if (editProvider
                                                                    .interestList
                                                                    .contains(data.id) ==
                                                                    true) {
                                                                  editProvider
                                                                      .removeHobi(data.id);
                                                                } else {
                                                                  if (editProvider.interestList.length <
                                                                      5) {
                                                                    editProvider
                                                                        .addInHobi(data.id);
                                                                  }
                                                                }
                                                              },
                                                              child:
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                    12,
                                                                    vertical:
                                                                    8),
                                                                decoration: BoxDecoration(
                                                                    color: editProvider.interestList.contains(data.id) ? AppColors.appColor : Theme.of(context).cardColor,
                                                                    borderRadius: BorderRadius.circular(
                                                                        40),
                                                                    border:
                                                                    Border.all(color: editProvider.interestList.contains(data.id) ? Colors.transparent : Theme.of(context).dividerTheme.color!)),
                                                                child:
                                                                Row(
                                                                  mainAxisSize:
                                                                  MainAxisSize.min,
                                                                  children: [
                                                                    Text(
                                                                        data.title.toString(),
                                                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: editProvider.interestList.contains(data.id) ? AppColors.white : null)),
                                                                    const SizedBox(
                                                                      width:
                                                                      5,
                                                                    ),
                                                                    Image
                                                                        .network(
                                                                      "${Config.baseUrl}${data.img}",
                                                                      height:
                                                                      24,
                                                                      width:
                                                                      24,
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          })
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)?.translate("Interests") ?? "Interests",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                        ,
                                      ),
                                      const Spacer(),
                                      SvgPicture.asset("assets/icons/Arrow - Right 2.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),)
                                    ],
                                  ),
                                  const SizBoxH(size: 0.008),
                                  Wrap(

                                    runSpacing: 13,
                                    children: [
                                      for (int a = 0; a < editProvider.interest!.length; a++)
                                        Builder(builder: (context) {
                                          Interestlist data =
                                          editProvider.interest![a];
                                          return (editProvider.interestList.contains(data.id)) ? Container(
                                            margin:  const EdgeInsets.symmetric(horizontal: 5),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context).cardColor,
                                                borderRadius:
                                                BorderRadius.circular(40),
                                                border: Border.all(color: Theme.of(context).dividerTheme.color!)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(data.title.toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Image.network(
                                                  "${Config.baseUrl}${data.img}",
                                                  height: 24,
                                                  width: 24,
                                                )
                                              ],
                                            ),
                                          ) : const SizedBox();
                                        })
                                    ],
                                  )
                                ],
                              ),
                            ),


                            const SizBoxH(size: 0.02),
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                    context: context,
                                    builder: (c) {
                                      editProvider =
                                          Provider.of<EditProfileProvider>(context,
                                              listen: false);
                                      return Consumer<EditProfileProvider>(
                                        builder: (context, bottomSheet, child) {
                                          return Container(
                                            height:
                                            MediaQuery.of(context).size.height /
                                                1.4,
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              borderRadius:
                                              BorderRadius.circular(16),
                                            ),
                                            child: Scaffold(
                                              bottomNavigationBar: MainButton(
                                                bgColor: AppColors.appColor,
                                                title:
                                                "Ok(${editProvider.languageList.length}/5)",
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              body: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    TextField(
                                                      controller: editProvider
                                                          .languageSearchContoller,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall!,
                                                      decoration: InputDecoration(
                                                        fillColor: Theme.of(context).cardColor,
                                                        filled: true,
                                                        contentPadding:
                                                        const EdgeInsets.all(
                                                            10),
                                                        hintText: AppLocalizations.of(context)?.translate("Search..") ?? "Search..",
                                                        hintStyle: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                        prefixIcon: SizedBox(
                                                            height: 20,
                                                            width: 20,
                                                            child: Center(
                                                                child: SvgPicture.asset("assets/icons/Search.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),))),
                                                        border: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Theme.of(context).dividerTheme.color!),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(12)),

                                                        enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Theme.of(context).dividerTheme.color!),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(12)),

                                                        disabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Theme.of(context).dividerTheme.color!),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(12)),

                                                        focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: AppColors.appColor),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(12)),
                                                      ),
                                                      onChanged: (c) {
                                                        editProvider
                                                            .searchLanguage(c);
                                                      },
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    editProvider
                                                        .languageSearchContoller
                                                        .text
                                                        .isEmpty
                                                        ? Wrap(
                                                      alignment:
                                                      WrapAlignment.start,
                                                      spacing: 13,
                                                      runSpacing: 13,
                                                      children: [
                                                        for (int a = 0;
                                                        a <
                                                            editProvider
                                                                .language!
                                                                .length;
                                                        a++)
                                                          Builder(builder:
                                                              (context) {
                                                            Languagelist
                                                            data =
                                                            editProvider
                                                                .language![a];
                                                            return InkWell(
                                                              onTap: () {

                                                                if (editProvider.languageList.contains(data.id) == true) {
                                                                  editProvider.removeLanguage(data.id);
                                                                } else {
                                                                  if (editProvider.languageList.length < 5) {
                                                                    editProvider.addInlanguage(data.id);
                                                                  }
                                                                }


                                                              },
                                                              child:
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                    12,
                                                                    vertical:
                                                                    8),
                                                                decoration: BoxDecoration(
                                                                    color: editProvider.languageList.contains(data.id) ? AppColors.appColor : Theme.of(context).cardColor,
                                                                    borderRadius:
                                                                    BorderRadius.circular(
                                                                        40),
                                                                    border: Border.all(
                                                                        color: editProvider.languageList.contains(data.id)
                                                                            ? Colors.transparent
                                                                            : Theme.of(context).dividerTheme.color!)),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                                  children: [
                                                                    Text(
                                                                        data.title
                                                                            .toString(),
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodySmall!
                                                                            .copyWith(color: editProvider.languageList.contains(data.id) ? AppColors.white : null)),
                                                                    const SizedBox(
                                                                      width:
                                                                      5,
                                                                    ),
                                                                    Image
                                                                        .network(
                                                                      "${Config.baseUrl}${data.img}",
                                                                      height:
                                                                      24,
                                                                      width:
                                                                      24,
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          })
                                                      ],
                                                    )
                                                        : editProvider
                                                        .searchForLanguage
                                                        .isEmpty
                                                        ? const SizedBox()
                                                        : Wrap(
                                                      alignment:
                                                      WrapAlignment
                                                          .start,
                                                      spacing: 13,
                                                      runSpacing: 13,
                                                      children: [
                                                        for (int a = 0;
                                                        a <
                                                            editProvider
                                                                .searchForLanguage
                                                                .length;
                                                        a++)
                                                          Builder(builder:
                                                              (context) {
                                                            var result =
                                                            editProvider
                                                                .searchForLanguage[a];
                                                            Languagelist
                                                            data =
                                                            editProvider
                                                                .language![
                                                            result];
                                                            return InkWell(
                                                              onTap: () {
                                                                if (editProvider
                                                                    .languageList
                                                                    .contains(data.id) ==
                                                                    true) {
                                                                  editProvider
                                                                      .removeLanguage(data.id);
                                                                } else {
                                                                  if (editProvider.languageList.length <
                                                                      5) {
                                                                    editProvider
                                                                        .addInlanguage(data.id);
                                                                  }
                                                                }
                                                              },
                                                              child:
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                    12,
                                                                    vertical:
                                                                    8),
                                                                decoration: BoxDecoration(
                                                                    color: editProvider.languageList.contains(data.id)
                                                                        ? AppColors
                                                                        .appColor
                                                                        : Theme.of(context).cardColor,
                                                                    borderRadius: BorderRadius.circular(
                                                                        40),
                                                                    border:
                                                                    Border.all(color: editProvider.languageList.contains(data.id) ? Colors.transparent : Theme.of(context).dividerTheme.color!)),
                                                                child:
                                                                Row(
                                                                  mainAxisSize:
                                                                  MainAxisSize.min,
                                                                  children: [
                                                                    Text(
                                                                        data.title.toString(),
                                                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: editProvider.languageList.contains(data.id) ? AppColors.white : null)),
                                                                    const SizedBox(
                                                                      width:
                                                                      5,
                                                                    ),
                                                                    Image
                                                                        .network(
                                                                      "${Config.baseUrl}${data.img}",
                                                                      height:
                                                                      24,
                                                                      width:
                                                                      24,
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          })
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)?.translate("Languages I Know") ?? "Languages I Know",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                        ,
                                      ),
                                      const Spacer(),
                                      SvgPicture.asset(
                                          "assets/icons/Arrow - Right 2.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),)
                                    ],
                                  ),
                                  const SizBoxH(size: 0.008),
                                  Wrap(
                                    runSpacing:   13,
                                    children: [
                                      for (int a = 0;
                                      a < editProvider.language!.length;
                                      a++)
                                        Builder(builder: (context) {
                                          Languagelist data = editProvider.language![a];
                                          return (editProvider.languageList.contains(data.id)) ? Container(
                                            margin:  const EdgeInsets.symmetric(horizontal: 5),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).cardColor,
                                                borderRadius:
                                                BorderRadius.circular(40),
                                                border: Border.all(color: Theme.of(context).dividerTheme.color!)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(data.title.toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Image.network(
                                                  "${Config.baseUrl}${data.img}",
                                                  height: 24,
                                                  width: 24,
                                                )
                                              ],
                                            ),
                                          ) : const SizedBox();
                                        })
                                    ],
                                  )
                                ],
                              ),
                            ),
                            const SizBoxH(size: 0.02),
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                    context: context,
                                    builder: (c) {
                                      editProvider =
                                          Provider.of<EditProfileProvider>(context,
                                              listen: false);
                                      return Consumer<EditProfileProvider>(
                                        builder: (context, bottomSheet, child) {
                                          return Container(
                                            height:
                                            MediaQuery.of(context).size.height /
                                                1.4,
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              borderRadius:
                                              BorderRadius.circular(16),
                                            ),
                                            child: Scaffold(
                                              bottomNavigationBar: MainButton(
                                                bgColor: AppColors.appColor,
                                                title: AppLocalizations.of(context)?.translate("Ok") ?? "Ok",
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              body: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    TextField(
                                                      controller: editProvider.religionSearchContoller,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall!,
                                                      decoration: InputDecoration(
                                                        filled: true,
                                                        fillColor: Theme.of(context).cardColor,
                                                        contentPadding:
                                                        const EdgeInsets.all(
                                                            10),
                                                        hintText: AppLocalizations.of(context)?.translate("Search..") ?? "Search..",
                                                        hintStyle: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                        prefixIcon: SizedBox(
                                                            height: 20,
                                                            width: 20,
                                                            child: Center(
                                                                child: SvgPicture.asset(
                                                                    "assets/icons/Search.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),))),
                                                        border: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Theme.of(context).dividerTheme.color!),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(12)),
                                                        enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Theme.of(context).dividerTheme.color!),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(12)),
                                                        disabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Theme.of(context).dividerTheme.color!),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(12)),
                                                        focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: AppColors
                                                                    .appColor),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(12)),
                                                      ),
                                                      onChanged: (c) {
                                                        editProvider
                                                            .searchReligion(c);
                                                      },
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    editProvider
                                                        .religionSearchContoller
                                                        .text
                                                        .isEmpty
                                                        ? Wrap(
                                                      spacing: 13,
                                                      runSpacing: 13,
                                                      children: [
                                                        for (int a = 0;
                                                        a <
                                                            editProvider
                                                                .religion!
                                                                .length;
                                                        a++)
                                                          Builder(builder:
                                                              (context) {
                                                            Religionlist
                                                            data =
                                                            editProvider
                                                                .religion![a];
                                                            return InkWell(
                                                              onTap: () {
                                                                editProvider.updatereligion(
                                                                    int.parse(data
                                                                        .id
                                                                        .toString()));
                                                              },
                                                              child:
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                    12,
                                                                    vertical:
                                                                    8),
                                                                decoration: BoxDecoration(
                                                                    color: editProvider.selectReligion ==
                                                                        int.parse(data.id
                                                                            .toString())
                                                                        ? AppColors
                                                                        .appColor
                                                                        : Theme.of(context).cardColor,
                                                                    borderRadius:
                                                                    BorderRadius.circular(
                                                                        40),
                                                                    border: Border.all(
                                                                        color: editProvider.selectReligion == int.parse(data.id.toString())
                                                                            ? Colors.transparent
                                                                            : Theme.of(context).dividerTheme.color!)),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                                  children: [
                                                                    Text(
                                                                        data.title
                                                                            .toString(),
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodySmall!
                                                                            .copyWith(color: editProvider.selectReligion == int.parse(data.id.toString()) ? AppColors.white : null)),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          })
                                                      ],
                                                    )
                                                        : editProvider
                                                        .searchForReligion
                                                        .isEmpty
                                                        ? const SizedBox()
                                                        : Wrap(
                                                      spacing: 13,
                                                      runSpacing: 13,
                                                      children: [
                                                        for (int a = 0;
                                                        a <
                                                            editProvider.searchForReligion.length;
                                                        a++)
                                                          Builder(builder:
                                                              (context) {
                                                            var result =
                                                            editProvider.searchForReligion[a];
                                                            Religionlist data = editProvider.religion![result];
                                                            return InkWell(
                                                              onTap: () {
                                                                editProvider.updatereligion(int.parse(data.id.toString()));
                                                              },
                                                              child:
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                    12,
                                                                    vertical:
                                                                    8),
                                                                decoration: BoxDecoration(
                                                                    color: editProvider.selectReligion == int.parse(data.id.toString())
                                                                        ? AppColors
                                                                        .appColor
                                                                        : Theme.of(context).cardColor,
                                                                    borderRadius: BorderRadius.circular(
                                                                        40),
                                                                    border:
                                                                    Border.all(color: editProvider.selectReligion == int.parse(data.id.toString()) ? Colors.transparent : Theme.of(context).dividerTheme.color!)),
                                                                child:
                                                                Row(
                                                                  mainAxisSize:
                                                                  MainAxisSize.min,
                                                                  children: [
                                                                    Text(data.title.toString(),
                                                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: editProvider.selectReligion == int.parse(data.id.toString()) ? AppColors.white : null)),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          })
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)?.translate("Religion") ?? "Religion",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            ,
                                      ),
                                      const Spacer(),
                                      SvgPicture.asset(
                                          "assets/icons/Arrow - Right 2.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),)
                                    ],
                                  ),
                                  const SizBoxH(size: 0.008),
                                  Wrap(

                                    runSpacing:13,
                                    children: [
                                      for (int a = 0;
                                      a < editProvider.religion!.length;
                                      a++)
                                        Builder(builder: (context) {
                                          Religionlist data =
                                          editProvider.religion![a];
                                          return (int.parse(data.id.toString()) ==
                                              editProvider.selectReligion)
                                              ? Container(
                                            margin:  const EdgeInsets.symmetric(horizontal: 5),
                                            padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8),
                                            decoration: BoxDecoration(
                                                // color: Colors.white,
                                              color: Theme.of(context).cardColor,
                                                borderRadius:
                                                BorderRadius.circular(40),
                                                border: Border.all(
                                                    color:
                                                    Theme.of(context).dividerTheme.color!)),
                                            child: Text(data.title.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    ),
                                          )
                                              : const SizedBox();
                                        })
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizBoxH(size: 0.02),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)?.translate("Search Preference") ?? "Search Preference",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          ,
                                    ),

                                  ],
                                ),
                                const SizBoxH(size: 0.008),
                                Wrap(
                                  runSpacing:13,
                                  children: [
                                    for (int a = 0;
                                    a < editProvider.searchPref.length;
                                    a++)
                                      Builder(builder: (context) {
                                        return  InkWell(
                                          onTap: () {
                                            editProvider.updateSearchPreference(a);
                                          },
                                          child: Container(
                                            margin:  const EdgeInsets.symmetric(horizontal: 5),
                                            padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8),
                                            decoration: BoxDecoration(
                                                color: editProvider.searchPreference == a ? AppColors.appColor :  Theme.of(context).cardColor,
                                                borderRadius:
                                                BorderRadius.circular(40),
                                                border: Border.all(
                                                    color:
                                                    editProvider.searchPreference == a ? AppColors.appColor : Theme.of(context).dividerTheme.color!)),
                                            child: Text(editProvider.searchPref[a].toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                    color:
                                                    editProvider.searchPreference == a ? AppColors.white : null)),
                                          ),
                                        );

                                      })
                                  ],
                                ),
                              ],
                            ),
                            const SizBoxH(size: 0.02),
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                    context: context,
                                    builder: (c) {
                                      editProvider =
                                          Provider.of<EditProfileProvider>(context,
                                              listen: false);
                                      return Consumer<EditProfileProvider>(
                                        builder: (context, bottomSheet, child) {
                                          return Container(
                                            height:
                                            MediaQuery.of(context).size.height /
                                                1.4,
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              borderRadius:
                                              BorderRadius.circular(16),
                                            ),
                                            child: Scaffold(
                                              bottomNavigationBar: MainButton(
                                                bgColor: AppColors.appColor,
                                                title: AppLocalizations.of(context)?.translate("Ok") ?? "Ok",
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              body: ListView.separated(
                                                  separatorBuilder: (c, i) {
                                                    return const SizBoxH(size: 0.012);
                                                  },
                                                  shrinkWrap: true,
                                                  itemCount: editProvider
                                                      .relationShip!.length,
                                                  itemBuilder: (c, i) {
                                                    Goallist? data = editProvider.relationShip![i];
                                                    return InkWell(
                                                      onTap: () {
                                                        editProvider
                                                            .updaterelationGoal(
                                                            int.parse(data.id
                                                                .toString()));
                                                      },
                                                      child: Container(
                                                        padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                        decoration: BoxDecoration(
                                                          color: Theme.of(context).cardColor,
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                12),
                                                            border: Border.all(
                                                                color: editProvider.selectRelationShip == int.parse(data.id.toString()) ? AppColors.appColor : Theme.of(context).dividerTheme.color!)),
                                                        width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            Text(
                                                              data.title.toString(),
                                                              style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                            ),
                                                            const SizBoxH(
                                                                size: 0.01),
                                                            Text(
                                                              data.subtitle
                                                                  .toString(),
                                                              style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                          );
                                        },
                                      );
                                    });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)?.translate("Relationship Goals") ?? "Relationship Goals",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            ,
                                      ),
                                      const Spacer(),
                                      SvgPicture.asset(
                                          "assets/icons/Arrow - Right 2.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),)
                                    ],
                                  ),
                                  const SizBoxH(size: 0.008),
                                  Wrap(

                                    runSpacing: 13,
                                    children: [
                                      for (int a = 0; a < editProvider.relationShip!.length; a++)
                                        Builder(
                                            builder: (context) {
                                          Goallist data =
                                          editProvider.relationShip![a];
                                          return (int.parse(data.id.toString()) == editProvider.selectRelationShip) ? Container(
                                            margin:  const EdgeInsets.symmetric(horizontal: 5),
                                            padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context).cardColor,
                                                borderRadius:
                                                BorderRadius.circular(40),
                                                border: Border.all(
                                                    color:
                                                    Theme.of(context).dividerTheme.color!)),
                                            child: Text(data.title.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    ),
                                          ) : const SizedBox();
                                        })
                                    ],
                                  )
                                ],
                              ),
                            ),
                            const SizBoxH(size: 0.02),
                            Row(
                              children: [
                                Text(AppLocalizations.of(context)?.translate("Height") ?? "Height",style: Theme.of(context).textTheme.bodyLarge!,),
                                const SizedBox(width: 10,),
                                Container(
                                  height: 25,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.appColor,
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  child:  Center(child: Text(AppLocalizations.of(context)?.translate("New") ?? "New",style: TextStyle(color: Colors.white,fontSize: 13),)),
                                )
                              ],
                            ),
                            ListTile(
                              onTap: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                    context: context,
                                    builder: (c) {
                                      editProvider = Provider.of<EditProfileProvider>(context, listen: false);
                                      return Consumer<EditProfileProvider>(
                                        builder: (context, bottomSheet, child) {
                                          return  Padding(
                                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                            child: Container(
                                              height: 250,
                                              padding: const EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: SafeArea(
                                                child: Scaffold(
                                                  bottomNavigationBar: MainButton(
                                                    bgColor: AppColors.appColor,
                                                    title: AppLocalizations.of(context)?.translate("Submit") ?? "Submit",
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      setState(() {
                                                      });
                                                    },
                                                  ),
                                                  resizeToAvoidBottomInset: false,
                                                  body: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(AppLocalizations.of(context)?.translate("Height") ?? "Height",style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 25,fontWeight: FontWeight.bold)),
                                                      Text(AppLocalizations.of(context)?.translate("Here is a chance to add height to your profile") ?? "Here is a chance to add height to your profile",style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 14,color: Colors.grey)),
                                                      const SizedBox(height: 10,),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Container(
                                                            height: 50,
                                                            width: 70,
                                                            alignment: Alignment.center,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                            child: TextField(
                                                              textAlign: TextAlign.center,
                                                              keyboardType: TextInputType.number,
                                                              controller: editProvider.heightcontrooler,
                                                              decoration: InputDecoration(
                                                                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                                                focusedBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(10)),borderSide: BorderSide(color: AppColors.appColor)),
                                                                enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)),borderSide: BorderSide(color: Colors.grey)),
                                                                hintText: '',
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 5,),
                                                          Text(AppLocalizations.of(context)?.translate("cm") ?? "cm",style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16))
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    });

                              },
                              contentPadding: EdgeInsets.zero,
                              leading: SvgPicture.asset("assets/icons/relere2.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),),
                              title: editProvider.heightcontrooler.text.isEmpty ? const Text("Not Updated") : Text("${editProvider.heightcontrooler.text} cm"),
                              trailing:  SvgPicture.asset(
                                "assets/icons/Arrow - Right 2.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),)
                            )
                          ]),
                    ),
                  ),

                  BlocBuilder<EditProfileCubit, EditProfileState>(
                    builder: (context, state){
                    if(state is EditInnerLoadingState) {
                      return CircularProgressIndicator(color: AppColors.appColor);
                    }
                    return const SizedBox();
                  },)

                ],
              );
            }
          },
        ));
  }

  Widget commenTile({required String titile,required Widget widget,required bool traing}){
    return Column(
      children: [

        Row(
          children: [

            Text(
              titile,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  ,
            ),

            const Spacer(),

            traing ? const SizedBox() : SvgPicture.asset("assets/icons/Arrow - Right 2.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),)

          ],
        ),

        const SizBoxH(size: 0.005),

        widget,

        const SizBoxH(size: 0.01),

      ],
    );
  }


}
