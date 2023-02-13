import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:medicalkit/Values.dart';
import 'package:medicalkit/camera.dart';
import 'package:medicalkit/detailMedication.dart';
import 'package:medicalkit/mqtt.dart';

class ShowMedication extends StatefulWidget {
  const ShowMedication({super.key});

  @override
  State<ShowMedication> createState() => _ShowMedication();
}

class _ShowMedication extends State<ShowMedication> {
  DateTime nowDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("箱内现存药物列表"),
      ),
      body: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          Center(
              child: ListView.builder(
                  itemCount: Values.medication.length,
                  itemBuilder: ((context, index) {
                    String beep = "0";
                    if (nowDateTime.compareTo(DateTime.parse(Values
                            .medication[index]["expiration"]
                            .toString())) >
                        0) {
                      beep = "1";
                      Mqtt.toPublish("beep", "1");
                    }

                    return Container(
                      color: beep == "1"
                          ? Color.fromARGB(127, 244, 67, 54)
                          : Colors.transparent,
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: ((context) => DetailMedication(
                                        index: index,
                                      ))))
                              .then((value) {
                            setState(() {});
                          });
                        },
                        title: Text(
                          Values.medication[index]["name"].toString(),
                          style: const TextStyle(fontSize: 20),
                        ),
                        trailing: Text(
                            Values.medication[index]["expiration"].toString(),
                            style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }))),
          Container(
            margin: const EdgeInsets.all(40),
            child: FloatingActionButton(
                child: const Text(
                  "+",
                  style: TextStyle(fontSize: 30),
                ),
                onPressed: () async {
                  WidgetsFlutterBinding.ensureInitialized();
                  try {
                    final cameras = await availableCameras();
                    final camera = cameras.first;
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: ((context) => Camera(camera: camera))))
                        .then((value) {
                      setState(() {});
                    });
                  } catch (e) {
                    showDialog(
                        context: context,
                        builder: ((context) => const AlertDialog(
                              title: Text("提示"),
                              content: Text("没有可访问的摄像头，请检查权限"),
                            )));
                  }
                }),
          )
        ],
      ),
    );
  }
}
