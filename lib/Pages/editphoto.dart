import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_painter/image_painter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_watermark/image_watermark.dart';

//import 'package:location_platform_interface/location_platform_interface.dart';

class EditPhotoPage extends StatefulWidget {
  final XFile photo;
  final String description;

  final List<double> coords;

  const EditPhotoPage(
      {super.key,
      required this.photo,
      required this.description,
      required this.coords});

  @override
  State<EditPhotoPage> createState() => _EditPhotoPageState();
}

class _EditPhotoPageState extends State<EditPhotoPage> {
  late img.Image image;
  Image? imageToShow;
  Uint8List memoryUint8List = Uint8List.fromList([]);
  bool useExtendedImageWidget = true;
  final _imageKey = GlobalKey<ImagePainterState>();

  @override
  void initState() {
    super.initState();
    memoryUint8List = File(widget.photo.path).readAsBytesSync();
    //
    //makeEditProcedures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                image = img.decodeJpg(memoryUint8List)!;
                image = img.copyRotate(image, -90);
                //File(widget.photo.path).writeAsBytesSync(img.encodeJpg(image), flush: true);
                memoryUint8List = Uint8List.fromList(img.encodeJpg(image));
                setState(() {
                  imageToShow = Image.memory(memoryUint8List);
                });
              },
              icon: const Icon(Icons.rotate_left)),
          IconButton(
              onPressed: () {
                image = img.decodeJpg(memoryUint8List)!;
                image = img.copyRotate(image, 90);
                memoryUint8List = Uint8List.fromList(img.encodeJpg(image));
                setState(() {
                  imageToShow = Image.memory(memoryUint8List);
                });
              },
              icon: const Icon(Icons.rotate_right)),
          IconButton(
              onPressed: () async {
                memoryUint8List =
                    (await _imageKey.currentState!.exportImage())!;
                var watermarkedUint8List =
                    await ImageWatermark.addTextWatermark(
                  imgBytes: memoryUint8List,
                  watermarkText: '${widget.description}\n${widget.coords}',
                  dstX: 0,
                  dstY: 0,
                  color: Colors.red,
                );
                memoryUint8List = watermarkedUint8List;

                _imageKey.currentState!.setState(() {});
                setState(() {});
              },
              icon: const Icon(Icons.place)),
          IconButton(
              onPressed: () {
                //File(widget.photo.path).writeAsBytesSync(memoryUint8List.toList(), flush: true);
                //widget.photo.saveTo(widget.photo.path);
                //XFile newPhoto = XFile.fromData(memoryUint8List, path: widget.photo.path);
                //newPhoto.saveTo(widget.photo.path);
                //File(widget.photo.path).writeAsBytesSync(img.encodeJpg(image));
                Navigator.of(context).pop(memoryUint8List);
              },
              icon: const Icon(Icons.save)),
        ],
      ),
      body: !useExtendedImageWidget
          ? SafeArea(
              child: imageToShow != null
                  ? AspectRatio(
                      aspectRatio: 1,
                      child: imageToShow,
                    )
                  : const Center(child: CircularProgressIndicator()))
          : SafeArea(
              child: ImagePainter.memory(memoryUint8List, key: _imageKey)),
    );
  }

  /*
  void makeEditProcedures() async {
    //File photoFile = File(widget.photo.path);
    image = img.decodeJpg(File(widget.photo.path).readAsBytesSync())!;
    image = img.bakeOrientation(image);
    print('image width: ${image.width}');
    print('image height: ${image.height}');
    //image = img.copyRotate(image, 90);
    print(image.exif.exifIfd.data);

    File(widget.photo.path).writeAsBytesSync(img.encodeJpg(image), flush: true);
    var t = await widget.photo.readAsBytes();

    final watermarkedImg = await ImageWatermark.addTextWatermark(
      imgBytes: memoryUint8List,
      watermarkText: '${widget.description}\n${widget.coords}',
      dstX: 0,
      dstY: 0,
      color: Colors.red,
    );
    File(widget.photo.path).writeAsBytesSync(watermarkedImg, flush: true);
    imageToShow = Image.file(File(widget.photo.path));
    memoryUint8List = watermarkedImg;
    _imageKey.currentState?.setState(() {});
  }*/
}
