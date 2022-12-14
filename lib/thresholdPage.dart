import 'package:flutter/material.dart';
import 'package:medicalkit/Values.dart';

class ThresholdPage extends StatefulWidget {
  const ThresholdPage({super.key});

  @override
  State<ThresholdPage> createState() => _ThresholdPageState();
}

class _ThresholdPageState extends State<ThresholdPage> {
  String tempThreshould = Values.tempThreshold.toString();
  String humiThreshould = Values.humiThreshold.toString();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("调整阈值"),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: TextFormField(
                  initialValue: Values.tempThreshold.toString(),
                  onChanged: ((value) => tempThreshould = value),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "温度阈值"),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: TextFormField(
                  initialValue: Values.humiThreshold.toString(),
                  onChanged: ((value) => humiThreshould = value),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "湿度阈值"),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      shadowColor: Colors.transparent,
                      backgroundColor: const Color.fromARGB(110, 76, 175, 79)),
                  onPressed: (() {
                    Values.tempThreshold = double.parse(tempThreshould);
                    Values.humiThreshold = double.parse(humiThreshould);
                    Navigator.of(context).pop();
                  }),
                  child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "确定",
                        style: TextStyle(fontSize: 18),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
