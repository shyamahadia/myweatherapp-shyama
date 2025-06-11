import 'package:flutter/material.dart';
import 'package:myweatherapp/worker/worker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myweatherapp/pages.dart/location.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  String city = "Mumbai";
  String temp = "";
  String hum = "";
  String air_speed = "";
  String desc = "";
  String main = "";
  String icon = "";

  @override
  void initState() {
    super.initState();

    // Use WidgetsBinding to ensure context is ready before accessing ModalRoute
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args.containsKey("searchText")) {
        city = args['searchText'] as String;
      } else {
        // Use location if no city passed via arguments
        try {
          LocationService locationService = LocationService();
          city = await locationService.getUserCity();
          print("📍 Detected location: $city");
        } catch (e) {
          print("❌ Location error: $e");
          city = "Mumbai"; // fallback city
        }
      }

      await startApp(city);
    });
  }

  Future<void> startApp(String city) async {
    Worker instance = Worker(location: city);
    await instance.getData();

    setState(() {
      temp = instance.temp;
      hum = instance.humidity;
      air_speed = instance.air_speed;
      desc = instance.description;
      main = instance.main;
      icon = instance.icon;
    });

    // Navigate after a short delay to show loading animation a bit
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {
          "temp_value": temp,
          "hum_value": hum,
          "air_speed_value": air_speed,
          "desc_value": desc,
          "main_value": main,
          "icon_value": icon,
          "city_value": city,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 65),
              Image.asset('assets/images/rain.png', height: 200, width: 200),

              const SizedBox(height: 50),
              const Text(
                "Weather App",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(168, 115, 150, 168),
                ),
              ),

              const SizedBox(height: 45),
              SpinKitThreeBounce(
                color: const Color.fromARGB(168, 115, 150, 168),
                size: 58.3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
