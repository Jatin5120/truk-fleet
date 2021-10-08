import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:photo_view/photo_view.dart';
import 'package:truk_fleet/company/controller/fleet_document_controller.dart';
import 'package:truk_fleet/locale/app_localization.dart';
import 'package:truk_fleet/locale/locale_keys.dart';
import 'package:file_picker/file_picker.dart';
import 'package:truk_fleet/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class FleetDocumentScreen extends StatefulWidget {
  @override
  _FleetDocumentScreenState createState() => _FleetDocumentScreenState();
}

class _FleetDocumentScreenState extends State<FleetDocumentScreen> {
  bool isAllNotUploaded = false;
  bool isLoading = true;
  final FleetDocumentController documentController = FleetDocumentController();
  File _adhaarFile;
  File _panFile;
  File _dlFile;
  File _selfiFile;
  File _companyRegistration;
  File _gstRegistration;
  File _bankProof;
  Map<String, dynamic> documentStatus = {
    FleetDocumentType.adhaar: [false, 'na'],
    FleetDocumentType.dl: [false, 'na'],
    FleetDocumentType.panCard: [false, 'na'],
    FleetDocumentType.selfie: [false, 'na'],
    FleetDocumentType.company_registration: [false, 'na'],
    FleetDocumentType.gst_registration: [false, 'na'],
    FleetDocumentType.bank_proof: [false, 'na'],
  };
  Locale locale;
  @override
  void initState() {
    super.initState();
    getDocsStatus();
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future getImage(ImageSource source, File f) async {
    var image = await ImagePicker().pickImage(source: source);
    if (image != null && mounted) {
      setState(() {
        f = File(image.path);
      });
    }
    return f;
  }

  getDocsStatus() async {
    isLoading = true;
    setState(() {});
    bool isAllNotUploaded = !await documentController.getMasterUploadStatus();
    if (!isAllNotUploaded) {
      documentStatus = await documentController.getPerticularUploadStatus();
    }
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  Widget uploadFleet({String title, void Function() onPressed}) {
    return Container(
      child: Row(
        children: [
          Container(
            child: Text(title),
          ),
          Container(
            child: InkWell(
              onTap: onPressed,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    locale = AppLocalizations.of(context).locale;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            AppLocalizations.getLocalizationValue(locale, LocaleKey.documents)),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          height: size.height,
          width: size.width,
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                )
              : buildUploadingDocuments(),
        ),
      ),
    );
  }

  Widget buildUploadButton(bool state, Function _onPressed, bool buttonState,
      File file, String docKey) {
    return Container(
      height: 65,
      padding: EdgeInsets.only(bottom: 20),
      child: FocusedMenuHolder(
        openWithTap: true,
        onPressed: () {
          print(docKey);
        },
        menuOffset: 5,
        bottomOffsetHeight: 10,
        menuWidth: MediaQuery.of(context).size.width * 0.8,
        menuItems: [
          FocusedMenuItem(
            title: Text("Camera"),
            trailingIcon: Icon(Icons.camera),
            onPressed: () async {
              File ff = await getImage(ImageSource.camera, file);
              if (ff != null) {
                setState(() {
                  isLoading = true;
                });
                await documentController.updateDocumentStatus(
                  docKey,
                  ff,
                );
                getDocsStatus();
              }
            },
          ),
          FocusedMenuItem(
            title: Text("Gallery"),
            trailingIcon: Icon(Icons.image),
            onPressed: () async {
              File ff = await getImage(ImageSource.gallery, file);
              if (ff != null) {
                setState(() {
                  isLoading = true;
                });
                await documentController.updateDocumentStatus(docKey, ff);
                getDocsStatus();
              }
            },
          ),
          FocusedMenuItem(
            title: Text("File"),
            trailingIcon: Icon(Icons.file_present),
            onPressed: () async {
              FilePickerResult result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: [
                    'jpg',
                    'png',
                    'jpeg',
                    'pdf',
                    'doc',
                    'docx'
                  ]);
              if (result != null) {
                File ff = File(result.files.single.path);
                if (ff != null) {
                  setState(() {
                    isLoading = true;
                  });
                  await documentController.updateDocumentStatus(
                    docKey,
                    ff,
                  );
                  getDocsStatus();
                }
              }
            },
          ),
          if (state)
            FocusedMenuItem(
              title: Text("View"),
              trailingIcon: Icon(Icons.view_carousel),
              onPressed: !state
                  ? null
                  : () {
                      String fileUrl = documentStatus[docKey][1];

                      String extenstion = fileUrl
                          .split("/")
                          .last
                          .split(".")
                          .last
                          .split("?")
                          .first;
                      print(extenstion);
                      bool isImage =
                          ['jpg', 'png', 'jpeg'].contains(extenstion);
                      if (!isImage) {
                        _launchURL(fileUrl);
                      } else
                        Platform.isAndroid
                            ? showMaterialModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  child: PhotoView(
                                    loadingBuilder: (context, progress) =>
                                        Center(
                                      child: Container(
                                        width: 50.0,
                                        height: 50.0,
                                        child: CircularProgressIndicator(
                                          value: progress == null
                                              ? null
                                              : progress.cumulativeBytesLoaded /
                                                  progress.expectedTotalBytes,
                                        ),
                                      ),
                                    ),
                                    imageProvider: NetworkImage(
                                      documentStatus[docKey][1],
                                      //placeholder: (ct, st) => Center(child: CircularProgressIndicator()),
                                    ),
                                  ),
                                ),
                              )
                            : showCupertinoModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  child: PhotoView(
                                    loadingBuilder: (context, progress) =>
                                        Center(
                                      child: Container(
                                        width: 50.0,
                                        height: 50.0,
                                        child: CircularProgressIndicator(
                                          value: progress == null
                                              ? null
                                              : progress.cumulativeBytesLoaded /
                                                  progress.expectedTotalBytes,
                                        ),
                                      ),
                                    ),
                                    imageProvider: NetworkImage(
                                      documentStatus[docKey][1],

                                      //placeholder: (ct, st) => Center(child: CircularProgressIndicator()),
                                    ),
                                  ),
                                ),
                              );
                    },
            ),
        ],
        child: Container(
          // elevation: 0.0,
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: state ? Color(0XFF4EDA87) : primaryColor,
          ),
          //onPressed: () {},
          child: buttonState
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      state ? Icons.check : Icons.arrow_upward,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      AppLocalizations.getLocalizationValue(locale,
                          state ? LocaleKey.uploaded : LocaleKey.upload),
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget buildDocument(
      String docKey, String documentName, bool documentState, File file) {
    bool buttonState = false;
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                documentName,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
              ),
            ),
          ),
          Expanded(
            child: buildUploadButton(
                documentState, () {}, buttonState, file, docKey),
          ),
        ],
      ),
    );
  }

  Widget buildUploadingDocuments() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20),
          alignment: Alignment.center,
          height: 60,
          child: Image(
            image: AssetImage('assets/images/logo.png'),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Column(
          children: [
            buildDocument(
                FleetDocumentType.dl,
                AppLocalizations.getLocalizationValue(locale, LocaleKey.dl),
                isAllNotUploaded
                    ? false
                    : documentStatus[FleetDocumentType.dl][0],
                _dlFile),
            buildDocument(
                FleetDocumentType.adhaar,
                AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.adharCard),
                isAllNotUploaded
                    ? false
                    : documentStatus[FleetDocumentType.adhaar][0],
                _adhaarFile),
            buildDocument(
                FleetDocumentType.panCard,
                AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.panCard),
                isAllNotUploaded
                    ? false
                    : documentStatus[FleetDocumentType.panCard][0],
                _panFile),
            buildDocument(
                FleetDocumentType.selfie,
                AppLocalizations.getLocalizationValue(locale, LocaleKey.selfie),
                isAllNotUploaded
                    ? false
                    : documentStatus[FleetDocumentType.selfie][0],
                _selfiFile),
            buildDocument(
                FleetDocumentType.company_registration,
                AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.company_registration),
                isAllNotUploaded
                    ? false
                    : documentStatus[FleetDocumentType.company_registration][0],
                _companyRegistration),
            buildDocument(
                FleetDocumentType.gst_registration,
                AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.gst_registration),
                isAllNotUploaded
                    ? false
                    : documentStatus[FleetDocumentType.gst_registration][0],
                _gstRegistration),
            buildDocument(
                FleetDocumentType.bank_proof,
                AppLocalizations.getLocalizationValue(
                    locale, LocaleKey.bank_proof),
                isAllNotUploaded
                    ? false
                    : documentStatus[FleetDocumentType.bank_proof][0],
                _bankProof),
          ],
        ),
        //buildButton(),
      ],
    );
  }
}
