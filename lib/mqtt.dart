import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:medicalkit/Values.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class Mqtt {
  static MqttServerClient client =
      MqttServerClient.withPort(Values.brokerIp, "107221", 10722);

  static Future<void> onDisconnected() async {
    print('OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('OnDisconnected callback is solicited, this is correct');
    }
    await client.connect();
  }

  static void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  static void onConnected() {
    print('OnConnected client callback - Client connection was sucessful');
  }

  static Future<void> toPublish(String topic, String text) async {
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(text);
    print('Publishing our topic');
    if (client.connectionStatus!.state != MqttConnectionState.connected) {
      await client.connect();
    }
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  static Future<void> mqttStart() async {
    client.logging(on: false);
    client.keepAlivePeriod = 3600;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    final connMess = MqttConnectMessage()
        .withClientIdentifier(getRandomString(10))
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.exactlyOnce);
    print('Client connecting....');
    client.connectionMessage = connMess;
    try {
      await client.connect();
    } catch (e) {
      print('Socket exception: $e');
      client.disconnect();
    }
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Client connected');
    }

    Mqtt.client.updates!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
      final resPayload = c![0].payload as MqttPublishMessage;
      final resTopic = c[0].topic;
      if (resTopic == "temperature") {
        Values.temperature = utf8.decode(resPayload.payload.message);
      } else if (resTopic == "humidity") {
        Values.humidity = utf8.decode(resPayload.payload.message);
      } else if (resTopic == "fanStatus") {
        //nodmcu只发0或1
        if (utf8.decode(resPayload.payload.message) == "0") {
          Values.fanState = false;
        } else if (utf8.decode(resPayload.payload.message) == "1") {
          Values.fanState = true;
        }
      } else if (resTopic == "esp32Picture") {
        //图像处理
        print("image lenth:${resPayload.payload.message.length}");
        String codebar;
        try {
          Values.camData = Uint8List.fromList(resPayload.payload.message);
          codebar = await scanner
              .scanBytes(Values.camData);
          print(codebar);
        } catch (e) {
          print(e);
          print("no image recognize");
        }
      }
      print("resTopic = $resTopic  resPayload = $resPayload");
    });
    //subscribe
    client.subscribe("temperature", MqttQos.exactlyOnce);
    client.subscribe("humidity", MqttQos.exactlyOnce);
    client.subscribe("fanStatus", MqttQos.exactlyOnce);
    client.subscribe("esp32Picture", MqttQos.exactlyOnce);
  }

  static String getRandomString(int length) {
    const characters =
        '+-*=?AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }
}
