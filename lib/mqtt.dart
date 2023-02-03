import 'dart:convert';
import 'dart:math';

import 'package:medicalkit/Values.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Mqtt {
  static MqttServerClient client = MqttServerClient.withPort(Values.brokerIp, "10722", 10722);

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

    Mqtt.client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
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
        }else if(utf8.decode(resPayload.payload.message) == "1"){
          Values.fanState = true;
        }
      }
      print("resTopic = $resTopic  resPayload = $resPayload");
    });
    //subscribe
    client.subscribe("temperature", MqttQos.exactlyOnce);
    client.subscribe("humidity", MqttQos.exactlyOnce);
    client.subscribe("fanStatus", MqttQos.exactlyOnce);
  }

  static String getRandomString(int length) {
    const characters =
        '+-*=?AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }
}
