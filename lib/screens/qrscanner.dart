import 'package:flutter/material.dart';
import 'package:camera/camera.dart';



class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late CameraController controller;
  late List<CameraDescription> cameras;


  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.isEmpty) {
      print('No camera available');
    } else {
      controller = CameraController(cameras[0], ResolutionPreset.high);
      await controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Stack(
        children: <Widget>[
          CameraPreview(controller),
          Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: SizedBox(
                      width: controller.value.previewSize?.height,
                      height: controller.value.previewSize?.width,
                      child: Stack(
                        children: <Widget>[
                          Opacity(
                            opacity: 0.7,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                backgroundBlendMode: BlendMode.dstOut,
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
