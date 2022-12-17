import 'dart:math';

import 'package:flutter/material.dart';
import 'package:medicalkit/Values.dart';
import 'package:http/http.dart' as http;

class DetailMedication extends StatefulWidget {
  const DetailMedication({super.key, required this.index});
  final int index;

  @override
  State<DetailMedication> createState() => _DetailMedicationState();
}

class _DetailMedicationState extends State<DetailMedication> {
  String expiration = "";

  @override
  void initState() {
    super.initState();
    expiration = Values.medication[widget.index]["expiration"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("详情")),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("用法：", style: TextStyle(fontSize: 20)),
                    Flexible(
                        child: Text(Values.medication[widget.index]["usage"],
                            style: const TextStyle(fontSize: 20)))
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("有效期至：", style: TextStyle(fontSize: 20)),
                    Flexible(
                        child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      initialValue: Values.medication[widget.index]
                          ["expiration"],
                      style: const TextStyle(fontSize: 20),
                      onChanged: (value) => expiration = value,
                    )),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20)),
                        onPressed: () {
                          http.post(Uri.parse("${Values.springUrl}/modify"),
                              body: {
                                "id": Values.medication[widget.index]["id"]
                                    .toString(),
                                "expiration": expiration
                              }).then((value) {
                            Values.medication[widget.index]["expiration"] =
                                expiration;
                            setState(() {});
                            showDialog(
                                context: context,
                                builder: ((context) => AlertDialog(
                                      title: const Text("提示"),
                                      content: const Text("修改成功"),
                                      actions: [
                                        TextButton(
                                            onPressed: (() {
                                              Navigator.of(context).pop();
                                            }),
                                            child: const Text("确定"))
                                      ],
                                    )));
                          });
                        },
                        child: const Text(
                          "保存",
                          style: TextStyle(fontSize: 20),
                        )),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("适应症：", style: TextStyle(fontSize: 20)),
                    Flexible(
                        child: Text(
                            Values.medication[widget.index]["indication"],
                            style: const TextStyle(fontSize: 20)))
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("不良反应：", style: TextStyle(fontSize: 20)),
                    Flexible(
                        child: Text(
                            Values.medication[widget.index]["side_effect"],
                            style: const TextStyle(fontSize: 20)))
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("注意事项：", style: TextStyle(fontSize: 20)),
                    Flexible(
                        child: Text(
                            Values.medication[widget.index]["attention"],
                            style: const TextStyle(fontSize: 20)))
                  ],
                ),
              ),
              ElevatedButton(
                  onPressed: (() {
                    http.post(Uri.parse("${Values.springUrl}/delete"), body: {
                      "id": Values.medication[widget.index]["id"].toString()
                    }).then((value) {
                      Values.medication.remove(Values.medication[widget.index]);
                      Navigator.of(context).pop();
                    });
                  }),
                  child: const Text(
                    "删除",
                    style: TextStyle(fontSize: 20),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
