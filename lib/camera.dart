import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:medicalkit/Values.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class Camera extends StatefulWidget {
  const Camera({super.key, required this.camera});
  final CameraDescription camera;

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late XFile image;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    _onPressed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("添加药品")),
      body: Center(),
    );
  }

  void _onPressed() async {
    String barcode = "";
    try {
      // await _initializeControllerFuture;
      // image = await _controller.takePicture();
      // barcode = await scanner.scanPath(image.path);
      barcode = (await scanner.scan())!;
    } catch (e) {
      showDialog(
          context: context,
          builder: ((context) => AlertDialog(
                title: const Text("提示"),
                content: const Text("错误，请重试"),
                actions: [
                  TextButton(
                      onPressed: (() {
                        Navigator.of(context).pop();
                      }),
                      child: const Text("确定"))
                ],
              )));
      return;
    }

    DateTime dateTime = DateTime.now();
    String day =
        dateTime.day < 10 ? "0${dateTime.day}" : dateTime.day.toString();
    String month =
        dateTime.month < 10 ? "0${dateTime.month}" : dateTime.month.toString();
    String hour =
        dateTime.hour < 10 ? "0${dateTime.hour}" : dateTime.hour.toString();
    String minute = dateTime.minute < 10
        ? "0${dateTime.minute}"
        : dateTime.minute.toString();
    String second = dateTime.second < 10
        ? "0${dateTime.second}"
        : dateTime.second.toString();
    String timestamp = "${dateTime.year}$month$day$hour$minute$second";
    String url = Values.apiUrl;
    url +=
        "code=$barcode&showapi_appid=${Values.appId}.0&showapi_timestap=$timestamp";
    String urlToSign =
        "code${barcode}showapi_appid${Values.appId}.0showapi_timestap$timestamp${Values.appKey}";
    var sign = md5.convert(utf8.encode(urlToSign)).toString().toLowerCase();
    url += "&showapi_sign=$sign";
    http.get(Uri.parse(url)).then((response) {
      var resBodyUtf8 = utf8.decode(response.bodyBytes);
      Map<String, dynamic> resBodyMap = jsonDecode(resBodyUtf8);
      Map<String, dynamic> showapi_res_body = resBodyMap["showapi_res_body"];
      String name = showapi_res_body["name"];
      String usage = showapi_res_body["dosage"];
      String attention = showapi_res_body["consideration"];
      String side_effect = showapi_res_body["other"];
      String indication = showapi_res_body["purpose"];
      Map<String, String> mp = {
        "name": name,
        "usage": usage,
        "attention": attention,
        "side_effect": side_effect,
        "expiration": timestamp.substring(0, 8),
        "indication": indication
      };
      http.post(Uri.parse("${Values.springUrl}/add"), body: mp);
      Values.medication.add(mp);
      Navigator.of(context).pop();
    });
  }
}
