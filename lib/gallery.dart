import 'dart:async';
import 'dart:io';
import 'package:android_external_storage/android_external_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class Gallery extends StatefulWidget {
  final String title = 'Gallery';

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  Future? _futureGetPath;
  List<dynamic> listImagePath = [];
  var _permissionStatus;

  @override
  void initState() {
    super.initState();
    _listenForPermissionStatus();
    _futureGetPath = _getPath();
  }

  File? imageFile;

  // @deprecated
  // void _getFromCamera() async {
  //
  //   final directory = await getExternalStorageDirectory();
  //   final myImagePath = '${directory!.path}/MyImages';
  //   print(myImagePath);
  //   final myImgDir = await Directory(myImagePath).create();
  //   XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
  //   final File? newImage = await File(pickedFile!.path).copy('${myImagePath.toString()}/image_${DateTime.now()}.jpg');
  //
  //
  //   setState(() {
  //     imageFile = File(pickedFile.path);
  //     print(pickedFile.path);
  //   });
  // }

  @override
  @deprecated
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: FutureBuilder(
              future: _futureGetPath,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  var dir = Directory(snapshot.data);
                  print('permission status: $_permissionStatus');
                  if (_permissionStatus) _fetchFiles(dir);
                  return Text(snapshot.data);
                } else {
                  return Text("Loading");
                }
              },
            ),
          ),
          Expanded(
            flex: 19,
            child: GridView.count(
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              children: _getListImg(listImagePath),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.camera_alt_outlined,
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => PreviewScreen()));
          // _getFromCamera();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16.0),
          ),
        ),
      ),
    );
  }

  void _listenForPermissionStatus() async {
    final status = await Permission.storage.request().isGranted;
    setState(() => _permissionStatus = status);
  }

  Future<String?> _getPath() {
    var imgPathIs = AndroidExternalStorage.getExternalStoragePublicDirectory(
        DirType.picturesDirectory);
    return imgPathIs;
  }

  _fetchFiles(Directory dir) {
    List<dynamic> listImage = [];
    dir.list().forEach((element) {
      RegExp regExp = new RegExp("\.(jpe?g|png|jpg)", caseSensitive: false);
      if (regExp.hasMatch('$element')) listImage.add(element);
      setState(() {
        listImagePath = listImage;
      });
    });
  }

  List<Widget> _getListImg(List<dynamic> listImagePath) {
    List<Widget> listImages = [];
    for (var imagePath in listImagePath) {
      listImages.add(
        Container(
          padding: const EdgeInsets.all(8),
          child: Image.file(imagePath, fit: BoxFit.cover),
        ),
      );
    }
    return listImages;
  }
}

class PreviewScreen extends StatefulWidget {
  // final String imgPath;
  // final String fileName;
  // PreviewScreen({required this.imgPath, required this.fileName});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  GlobalKey _globalKey = GlobalKey();
  File? imageFile;
  void _getFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    final File newImage = await File(pickedFile!.path);

    setState(() {
      imageFile = File(pickedFile.path);
    });
  }

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _getFromCamera();
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
                      icon: Icon(
                        Icons.save_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _saveScreen();
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => Gallery()));
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
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
    ByteData? byteData = await (image.toByteData(format: ui.ImageByteFormat.png)
        as FutureOr<ByteData?>);
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
