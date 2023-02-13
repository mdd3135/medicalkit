import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:medicalkit/Values.dart';
import 'package:medicalkit/mqtt.dart';
import 'package:medicalkit/showMedication.dart';
import 'package:medicalkit/thresholdPage.dart';
import 'package:http/http.dart' as http;

void main() {
  http.get(Uri.parse("${Values.springUrl}/query")).then(
    (response) {
      String resBodyutf8 = utf8.decode(response.bodyBytes);
      Map<String, dynamic> resMap = jsonDecode(resBodyutf8);
      List<dynamic> content = resMap["content"];
      for (int i = 0; i < content.length; i++) {
        Map<String, dynamic> item = content[i];
        Values.medication.add(item);
      }
    },
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: '首页'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Mqtt.mqttStart();
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 100,
                      height: 100,
                      color: const Color.fromARGB(68, 121, 85, 72),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            alignment: AlignmentDirectional.topStart,
                            child: const Text(
                              "温度",
                              style: TextStyle(fontSize: 24),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Container(
                            margin:
                                const EdgeInsets.only(right: 10, bottom: 10),
                            alignment: AlignmentDirectional.bottomEnd,
                            child: Text(
                              Values.temperature,
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    )),
                    Expanded(
                        child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      width: 100,
                      height: 100,
                      color: const Color.fromARGB(103, 33, 149, 243),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            alignment: AlignmentDirectional.topStart,
                            child: const Text(
                              "湿度",
                              style: TextStyle(fontSize: 24),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Container(
                            margin:
                                const EdgeInsets.only(bottom: 10, right: 10),
                            alignment: AlignmentDirectional.bottomEnd,
                            child: Text(
                              Values.humidity,
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  height: 50,
                  color: const Color.fromARGB(61, 158, 158, 158),
                  child: Row(children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: const Text(style: TextStyle(fontSize: 24), "风扇状态"),
                    ),
                    const Expanded(child: Text("")),
                    Container(
                        margin: const EdgeInsets.only(right: 10),
                        alignment: AlignmentDirectional.centerEnd,
                        // alignment: AlignmentDirectional.centerEnd,
                        child: Icon(Values.fanState == true
                            ? Icons.done
                            : Icons.close)),
                  ]),
                ),
                Container(
                  width: 180,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 186, 231, 188)),
                    onPressed: (() {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: ((context) => const ThresholdPage())));
                    }),
                    child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "改变温度阈值",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        )),
                  ),
                ),
                Container(
                  width: 180,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color.fromARGB(255, 186, 231, 188)),
                    onPressed: (() {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ShowMedication()));
                    }),
                    child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "查看药箱内药品",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
