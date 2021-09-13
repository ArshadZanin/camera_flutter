import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


// class CameraScreen extends StatefulWidget {
//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   CameraController? cameraController;
//   List? cameras;
//   late int selectedCameraIndex;
//   String? imgPath;



//   Future initCamera(CameraDescription cameraDescription) async {
//     if (cameraController != null) {
//       await cameraController!.dispose();
//     }

//     cameraController =
//         CameraController(cameraDescription, ResolutionPreset.high);

//     cameraController!.addListener(() {
//       if (mounted) {
//         setState(() {});
//       }
//     });

//     if (cameraController!.value.hasError) {
//       print('Camera Error ${cameraController!.value.errorDescription}');
//     }

//     try {
//       await cameraController!.initialize();
//     } catch (e) {
//       showCameraException(e);
//     }

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   /// Display camera preview
//   Widget cameraPreview() {
//     if (cameraController == null || !cameraController!.value.isInitialized) {
//       return Text(
//         'Loading',
//         style: TextStyle(
//             color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
//       );
//     }

//     return AspectRatio(
//       aspectRatio: cameraController!.value.aspectRatio,
//       child: CameraPreview(cameraController!),
//     );
//   }

//   Widget cameraControl(context) {
//     return Expanded(
//       child: Align(
//         alignment: Alignment.center,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           mainAxisSize: MainAxisSize.max,
//           children: <Widget>[
//             FloatingActionButton(
//               child: Icon(
//                 Icons.camera,
//                 color: Colors.black,
//               ),
//               backgroundColor: Colors.white,
//               onPressed: () {
//                 onCapture(context);
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget cameraToggle() {
//     if (cameras == null || cameras!.isEmpty) {
//       return Spacer();
//     }

//     CameraDescription selectedCamera = cameras![selectedCameraIndex];
//     CameraLensDirection lensDirection = selectedCamera.lensDirection;

//     return Expanded(
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: FlatButton.icon(
//             onPressed: () {
//               onSwitchCamera();
//             },
//             icon: Icon(
//               getCameraLensIcons(lensDirection),
//               color: Colors.white,
//               size: 24,
//             ),
//             label: Text(
//               '${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1).toUpperCase()}',
//               style:
//               TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
//             )),
//       ),
//     );
//   }

//   onCapture(context) async {
//     try {
//       final p = await getTemporaryDirectory();
//       final name = DateTime.now();
//       final path = "${p.path}/$name.png";

//       await cameraController!.takePicture().then((value) {
//         print('here');
//         print(path);
//         Navigator.push(context, MaterialPageRoute(builder: (context) =>PreviewScreen(imgPath: path,fileName: "$name.png",)));
//       });

//     } catch (e) {
//       showCameraException(e);
//     }
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     availableCameras().then((value) {
//       cameras = value;
//       if(cameras!.length > 0){
//         setState(() {
//           selectedCameraIndex = 0;
//         });
//         initCamera(cameras![selectedCameraIndex]).then((value) {

//         });
//       } else {
//         print('No camera available');
//       }
//     }).catchError((e){
//       print('Error : ${e.code}');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Container(
//         child: Stack(
//           children: <Widget>[
// //            Expanded(
// //              flex: 1,
// //              child: _cameraPreviewWidget(),
// //            ),
//             Align(
//               alignment: Alignment.center,
//               child: cameraPreview(),
//             ),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 height: 120,
//                 width: double.infinity,
//                 padding: EdgeInsets.all(15),
//                 color: Colors.transparent,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: <Widget>[
//                     cameraToggle(),
//                     cameraControl(context),
//                     Spacer(),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   getCameraLensIcons(lensDirection) {
//     switch (lensDirection) {
//       case CameraLensDirection.back:
//         return CupertinoIcons.switch_camera;
//       case CameraLensDirection.front:
//         return CupertinoIcons.switch_camera_solid;
//       case CameraLensDirection.external:
//         return CupertinoIcons.photo_camera;
//       default:
//         return Icons.device_unknown;
//     }
//   }

//   onSwitchCamera() {
//     selectedCameraIndex =
//     selectedCameraIndex < cameras!.length - 1 ? selectedCameraIndex + 1 : 0;
//     CameraDescription selectedCamera = cameras![selectedCameraIndex];
//     initCamera(selectedCamera);
//   }

//   showCameraException(e) {
//     String errorText = 'Error ${e.code} \nError message: ${e.description}';
//   }
// }







class PreviewScreen extends StatefulWidget {
  final String imgPath;
  final String fileName;
  PreviewScreen({required this.imgPath, required this.fileName});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  GlobalKey _globalKey = GlobalKey();
    File? imageFile;
  void _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    setState(() {
      imageFile = File(pickedFile!.path);
    });
  }

  @override
  void initState() {
    super.initState();
    _requestPermission();
      if (mounted) {
        return;
      }
      setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    child: Image.file(imageFile!),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  color: Colors.black,
                  child: Center(
                    child: IconButton(
                      icon: Icon(Icons.save_outlined,color: Colors.white,),
                      onPressed: _saveScreen,
                    ),
                  ),
                ),
              )
            ],
          ),
        )
    );
  }


  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
    _toastInfo(info);
  }

  _saveScreen() async {
    RenderRepaintBoundary boundary =
    _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await (image.toByteData(format: ui.ImageByteFormat.png) as FutureOr<ByteData?>);
    if (byteData != null) {
      final result =
      await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
      print(result);
      _toastInfo(result.toString());
    }
  }

  _toastInfo(String info) {
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }
}



//
//
// List<CameraDescription>? cameras;
//
//
// class MyHomePage2 extends StatefulWidget {
//   @override
//   _MyHomePage2State createState() => _MyHomePage2State();
// }
//
// class _MyHomePage2State extends State<MyHomePage2> {
//   GlobalKey _globalKey = GlobalKey();
//   CameraController? controller;
//
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermission();
//     controller = CameraController(cameras![0], ResolutionPreset.max);
//     controller!.initialize().then((_) {
//       if (mounted) {
//         return;
//       }
//       setState(() {});
//     });
//   }
//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("Save image to gallery"),
//         ),
//         body: Center(
//           child: Column(
//             children: <Widget>[
//               RepaintBoundary(
//                 key: _globalKey,
//                 child: Container(
//                   width: 400,
//                   height: 400,
//                   child: CameraPreview(controller!),
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.only(top: 15),
//                 child: RaisedButton(
//                   onPressed: _saveScreen,
//                   child: Icon(Icons.circle),
//                 ),
//                 width: 200,
//                 height: 44,
//               ),
//             ],
//           ),
//         ));
//   }
//
//   _requestPermission() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.storage,
//     ].request();
//
//     final info = statuses[Permission.storage].toString();
//     print(info);
//     _toastInfo(info);
//   }
//
//   _saveScreen() async {
//     RenderRepaintBoundary boundary =
//     _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//     ui.Image image = await boundary.toImage();
//     ByteData? byteData = await (image.toByteData(format: ui.ImageByteFormat.png) as FutureOr<ByteData?>);
//     if (byteData != null) {
//       final result =
//       await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
//       print(result);
//       _toastInfo(result.toString());
//     }
//   }
//   _toastInfo(String info) {
//     Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
//   }
// }
//
