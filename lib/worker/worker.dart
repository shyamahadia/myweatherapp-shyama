import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myweatherapp/secrets.dart';

class Worker {
  String location;
  // Constructor with required location
  Worker({required this.location});
  String temp = '';
  String humidity = '';
  String air_speed = '';
  String description = '';
  String main = '';
  String icon = '';
  Future<void> getData() async {
    try {
      http.Response response = await http.get(
        Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?q=$location&appid=${Secrets.openWeatherApiKey}",
        ),
      );

      Map data = jsonDecode(response.body);
      print(data);
      //getting temp,humidity,air_speed
      Map tempData = data['main'];
      Map wind = data['wind'];
      double getairSpeed = wind['speed'] * 3.6;
      String getHumidity = tempData['humidity'].toString();
      double getTemp = tempData['temp'] - 273.15;
      //temp = getTemp.toStringAsFixed(2); // 2 decimal places

      //getting description
      List weatherData = data['weather'];
      Map weatherMainData = weatherData[0];
      String getmainDes = weatherMainData['main'];
      String getDesc = weatherMainData['description'];

      temp = getTemp.toString();

      humidity = getHumidity;
      air_speed = getairSpeed.toString();
      description = getDesc;
      main = getmainDes;
      icon = weatherMainData["icon"].toString();
    } catch (e) {
      temp = "NA";
      humidity = "NA";
      air_speed = "NA";
      description = "Can't find";
      main = "NA";
      icon = "09d";
    }
  }
}
