import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController mobile = TextEditingController();
  final picker = ImagePicker();
  File? localprofilepic;
  bool isUpdated = false;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final profile = AppConstants.profile;

    if (profile != null) {
      name.text = profile.name;
      email.text = profile.email;
      mobile.text = profile.mobile;
    }
  }

  void pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        localprofilepic = File(pickedFile.path);
        isUpdated = true;
      });
    }
  }

  void checkIfUpdated() {
    final profile = AppConstants.profile;

    final currentName = name.text.trim();
    final currentEmail = email.text.trim();
    final currentMobile = mobile.text.trim();

    // ✅ Ensure required fields are NOT empty
    final allRequiredFilled =
        currentName.isNotEmpty &&
        currentEmail.isNotEmpty &&
        currentMobile.isNotEmpty;

    // ✅ Check what's changed
    final hasNameChanged = currentName != profile?.name.trim();
    final hasEmailChanged = currentEmail != profile?.email.trim();
    final hasMobileChanged = currentMobile != profile?.mobile.trim();
    final hasImageChanged = localprofilepic != null;

    // ✅ Only allow update if required fields are filled AND at least one thing changed
    final somethingChanged =
        hasNameChanged ||
        hasEmailChanged ||
        hasMobileChanged ||
        hasImageChanged;
    setState(() {
      isUpdated = allRequiredFilled && somethingChanged;
    });
  }

  void updateProfile() async {
    FocusScope.of(context).unfocus();
    setState(() => isUpdated = false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = AppConstants.profile;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColor.blackColor,
                      backgroundImage:
                          localprofilepic != null
                              ? FileImage(localprofilepic!)
                              : (profile?.imageUrl.isNotEmpty ?? false)
                              ? NetworkImage(profile!.imageUrl)
                              : null,
                      child:
                          localprofilepic == null &&
                                  (profile?.imageUrl.isEmpty ?? true)
                              ? Text(
                                profile?.name[0].toUpperCase() ?? "G",
                                style: Styles.textExtraHugeBold(
                                  context,
                                  color: AppColor.whiteColor,
                                ),
                                textScaler: const TextScaler.linear(1.0),
                              )
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: bottomSheetImage,
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          child: Icon(Icons.edit, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              buildTextField("Name", name, isEditable: true),
              buildTextField("Email", email, isEditable: true),
              buildTextField("Mobile", mobile, isEditable: false),

              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isUpdated ? updateProfile : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isUpdated ? AppColor.maincolor : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Update Profile",
                    style: Styles.textStyleMedium(context, color: Colors.white),
                    textScaler: TextScaler.linear(1.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget divider() =>
      const Divider(height: 1, thickness: .5, color: Colors.black12);

Widget buildTextField(
  String label,
  TextEditingController controller, {
  required bool isEditable,
}) {
  final bool isMobileField = label.toLowerCase() == "mobile";

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      child: TextFormField(
        controller: controller,
        readOnly: !isEditable,
        onChanged: (_) => checkIfUpdated(),
        style: Styles.textStyleMedium(context),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: Styles.textStyleMedium(context, color: AppColor.hintTextColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 0.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 0.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 0.5),
          ),
          suffixIcon: isEditable && controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      controller.clear();
                      checkIfUpdated();
                    });
                  },
                )
              : !isEditable && isMobileField
                  ? TextButton(
                      onPressed: () {
                        // ✅ TODO: handle change mobile tap
                      
                      }, 
                      child: Text(
                        "Change",
                        style: Styles.textStyleMedium(context, color: AppColor.maincolor),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    )
                  : null,
        ),
      ),
    ),
  );
}


  bottomSheetImage() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library, color : AppColor.maincolor),
                title: Text(
                  'Photo Library',
                  style: Styles.textStyleLarge(
                    context,
                    color: AppColor.blackColor,
                  ),
                  textScaler: TextScaler.linear(1.0),
                ),
                onTap: () {
                  getPicFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera, color: AppColor.maincolor),
                title: Text(
                  'Camera',
                  style: Styles.textStyleLarge(
                    context,
                    color: AppColor.blackColor,
                  ),
                  textScaler: TextScaler.linear(1.0),
                ),
                onTap: () {
                  getPicFromCam();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future getPicFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        localprofilepic = File(pickedFile.path);
        checkIfUpdated();
      });
      _cropImage(); // ✅ Only call _cropImage() when localprofilepic is set
    }
    Navigator.pop(context);
  }

  Future getPicFromCam() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        localprofilepic = File(pickedFile.path);
        checkIfUpdated();
      });
      _cropImage(); // ✅ Only call _cropImage() when localprofilepic is set
    }
    Navigator.pop(context);
  }

  Future<void> _cropImage() async {
    if (localprofilepic == null) return; // ✅ Prevents null exception

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: localprofilepic!.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: AppColor.blackColor,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColor.blackColor,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Cropper'),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        localprofilepic = File(croppedFile.path);
        checkIfUpdated();
      });

      // Convert image to bytes if needed
      //final bytes = await Io.File(localprofilepic!.path).readAsBytes();
    }
  }
}
