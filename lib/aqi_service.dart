import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Station {
  String siteName = '';
  String county = '';
  String status = '';
  String publishTime = '';
  int? aqi = -1;
  int? PM2 = -1;

  Station({required this.siteName});

  Station.fromJson(Map<String, dynamic> json) {
    siteName = json['SiteName'];
    county = json['County'];
    status = json['Status'];
    publishTime = json['PublishTime'];
    aqi = int.tryParse(json['AQI']) ?? -1;
    PM2 = int.tryParse(json['PM2.5']) ?? -1;
  }
}
Future<List<Station>> fetchAQI() async {
  List<Station> stations = [];
  final response = await http.get(Uri.parse(
      'https://data.epa.gov.tw/api/v1/aqx_p_432?format=json&offset=0&limit=100&api_key=輸入環保署API Key'));

  debugPrint('response gotten');
  if (response.statusCode == 200) {
    debugPrint('result gotten');
    var res = jsonDecode(response.body);
    List<dynamic> stationsInJson = res['records'];
    for (var station in stationsInJson) {
      // debugPrint(station['SiteName']);
      stations.add(Station.fromJson(station));
    }
    debugPrint('${stations.length} stations gotten');
  } else {
    debugPrint('status code:${response.statusCode}');
  }
  return stations;
}

