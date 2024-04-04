import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salarynow/widgets/dialog_box_widget.dart';
import 'package:salarynow/widgets/loader.dart';
import '../../dashboard/cubit/get_selfie_cubit/get_selfie_cubit.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../utils/on_screen_loader.dart';
import '../../utils/snackbar.dart';
import '../../widgets/camera_button.dart';
import '../cubit/req_doc_cubit/req_document_cubit.dart';
import '../cubit/selfie_cubit/selfie_cubit.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:image/image.dart' as img;

class SelfieScreen extends StatefulWidget {
  const SelfieScreen({Key? key}) : super(key: key);

  @override
  State<SelfieScreen> createState() => _SelfieScreenState();
}

class _SelfieScreenState extends State<SelfieScreen> {
  late List<CameraDescription> cameras;
  CameraController? cameraController;

  int direction = 1;

  @override
  void initState() {
    super.initState();
    startCamera(direction);
  }

  int turns = 0;

  void startCamera(int direction) async {
    cameras = await availableCameras();

    cameraController = CameraController(
      cameras[direction],
      ResolutionPreset.high,
      enableAudio: false,
    );
    print("Orientation1 - ${cameraController?.value.deviceOrientation.index}");
    print("Orientation2 - ${cameraController?.value.description.sensorOrientation}");
    print("Orientation3 - ${cameraController?.value.description.name}");
    var orientation = cameraController?.value.description.sensorOrientation;

    setState(() {
      if (orientation == 90) {
        turns = 1;
      } else if (orientation == 180) {
        turns = 2;
      } else if (orientation == 270) {
        turns = 0;
      } else if (orientation == 360) {
        turns = 3;
      }
    });

    await cameraController!.initialize().then((value) {
      // cameraController?.description.sensorOrientation = 90;
      // cameraController?.value = cameraController!.value.copyWith(
      //   description: CameraDescription(name: cameras[direction].name, lensDirection: cameras[direction].lensDirection, sensorOrientation: 180),
      // );
      if (!mounted) {
        return;
      }
      setState(() {}); //To refresh widget
    }).catchError((e) {
      MyDialogBox.openSelfiePermissionAppSetting(
          context: context,
          error: 'Give Camera permission',
          onPressed: () {
            openAppSettings();
            Navigator.pop(context);
            Navigator.pop(context);
          });
    });
  }

  @override
  void dispose() {
    cameraController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: cameraController == null
            ? const MyLoader()
            : cameraController!.value.isInitialized
                ? Stack(
                    children: [
                      Container(
                        height: double.infinity,
                        width: double.infinity,
                        child: CameraPreview(cameraController!),
                      ),
                      // Container(
                      //   height: double.infinity,
                      //   width: double.infinity,
                      //   child: RotatedBox(
                      //     quarterTurns: turns,
                      //     child: CameraPreview(cameraController!),
                      //   ),
                      // ),
                      BlocListener<ReqDocumentCubit, ReqDocumentState>(
                        listener: (context, state) {
                          if (state is ReqDocumentLoading) {
                            MyScreenLoader.onScreenLoader(context);
                          }
                          if (state is ReqDocumentError) {
                            Navigator.pop(context);
                            MySnackBar.showSnackBar(context, "Uploading Error");
                          }
                          if (state is ReqDocumentLoaded) {
                            MySnackBar.showSnackBar(context, "Selfie Image Uploaded");
                            Navigator.pop(context);
                            Navigator.pop(context);
                            var getSelfieCubit = GetSelfieCubit.get(context);
                            getSelfieCubit.getSelfie(doctype: 'selfie');
                            var profileCubit = ProfileCubit.get(context);
                            profileCubit.getProfile();
                          }
                        },
                        child: BlocListener<SelfieCubit, SelfieState>(
                          listener: (context, state) {
                            if (state is SelfieLoadingState) {
                              MyScreenLoader.onScreenLoader(context);
                            }
                            if (state is SelfieErrorState) {
                              Navigator.pop(context);
                              MySnackBar.showSnackBar(context, state.error);
                            }
                            if (state is SelfieLoadedState) {
                              Navigator.pop(context);
                              var selfieCubit = ReqDocumentCubit.get(context);

                              selfieCubit.postSelfie(
                                  location: state.place,
                                  file: state.file,
                                  latitude: state.position.latitude.toString(),
                                  longitude: state.position.longitude.toString());
                            }
                          },
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 20.h),
                              child: MyCameraButton(onTap: () {
                                cameraController!.takePicture().then((XFile? file) {
                                  if (mounted) {
                                    final image = img.decodeImage(File(file!.path).readAsBytesSync());
                                    final flippedImage = img.flipHorizontal(image!);

                                    File flippedFile = File(file!.path)..writeAsBytesSync(img.encodeJpg(flippedImage));
                                    XFile flippedXFile = XFile(flippedFile.path);
                                    var selfieCubit = SelfieCubit.get(context);
                                    selfieCubit.getSelfie(flippedXFile);
                                  }
                                });
                              }),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const MyLoader());
  }

  Widget button(IconData icon, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(
          left: 20,
          bottom: 20,
        ),
        height: 50,
        width: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
