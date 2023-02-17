import 'dart:typed_data';

class Values {
  static String springUrl = "http://ywj-tmp.vip.cpolar.top";
  static String brokerIp = "1.tcp.vip.cpolar.top";
  static String temperature = "25.2C";
  static String humidity = "49%";
  static bool fanState = false;
  static double tempThreshold = 20;
  static double humiThreshold = 50;
  static List<Map<String, dynamic>> medication = [
    // {"name": "name1", "expiration": "expiration1"},
    // {"name": "name1", "expiration": "expiration1"}
  ];
  static String appKey = "4fbe1372d50d44b2b338cd4df5f77719";
  static String appId = "1338478";
  static String apiSign = '';
  static String apiUrl = "https://route.showapi.com/66-24?";
  static Uint8List camData = Uint8List(0);
}
