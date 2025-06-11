import 'dart:math';
import 'package:flutter/material.dart';
import 'chatbot_screen.dart';
import 'package:myweatherapp/pages.dart/location_service.dart' as locSevice;
import 'package:myweatherapp/secrets.dart'; // adjust path if needed

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController searchController = TextEditingController();
  bool isGettingLocation = true;
  bool hasRedirected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args == null && !hasRedirected) {
        hasRedirected = true;
        _getLocationAndWeather(); // Call location fetch on start if needed
      }
    });
  }

  Future<void> _getLocationAndWeather() async {
    setState(() {
      isGettingLocation = false;
    });
    try {
      locSevice.LocationService locationService = locSevice.LocationService();
      final city = await locationService.getUserCity();
      final searchText = city;

      Navigator.pushReplacementNamed(
        context,
        "/loading",
        arguments: {"searchText": searchText},
      );
    } catch (e) {
      print("Error getting location or weather: $e");
      setState(() {
        isGettingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cityList = ["Ahmedabad", "Mumbai", "Delhi"];
    final random = Random();
    final city = cityList[random.nextInt(cityList.length)];

    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    // Handle case if args is null (app started without weather data)
    if (args == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Text(
              'Please search for a city to get weather data.',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    // Extract weather data safely
    String temp = args['temp_value']?.toString() ?? "NA";
    String air = args['air_speed_value']?.toString() ?? "NA";
    String hum = args['hum_value']?.toString() ?? "NA";
    String desc = args['desc_value']?.toString() ?? "";
    String getcity = args['city_value']?.toString() ?? "";
    String icon = args['icon_value']?.toString() ?? "";

    if (temp != "NA" && temp.length >= 4) {
      temp = temp.substring(0, 4);
    }
    if (air != "NA" && air.length >= 4) {
      air = air.substring(0, 4);
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 151, 171, 210), Color(0xFFCFDEF3)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: [0.1, 0.5],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(234, 252, 249, 249),
                    borderRadius: BorderRadius.circular(31),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (searchController.text.trim().isEmpty) {
                            print("blank search not supported");
                            return;
                          } else {
                            Navigator.pushReplacementNamed(
                              context,
                              "/loading",
                              arguments: {
                                "searchText": searchController.text.trim(),
                              },
                            );
                          }
                        },
                        child: const Icon(
                          Icons.search,
                          size: 28,
                          color: Color.fromARGB(255, 55, 113, 214),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Search $city...",
                            hintStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.blueGrey,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withOpacity(0.5),
                  ),
                  child: Row(
                    children: [
                      Image.network(
                        icon.isNotEmpty
                            ? "https://openweathermap.org/img/wn/$icon@2x.png"
                            : "https://openweathermap.org/img/wn/03n@2x.png",
                        height: 50,
                        width: 50,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              desc,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              getcity,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  height: 260,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withOpacity(0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.thermostat),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            temp,
                            style: const TextStyle(
                              fontSize: 75,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "°C",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 170,
                        margin: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white.withOpacity(0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.wind_power),
                            const SizedBox(height: 10),
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    air,
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text("km/hr"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 170,
                        margin: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white.withOpacity(0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.percent_outlined),
                            const SizedBox(height: 10),
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    hum,
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text("Percent"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ChatbotScreen(
                              openAiApiKey:
                                  Secrets.openAiApiKey,
                              weatherApiKey:
                                  Secrets
                                      .openWeatherApiKey, // just API key, not full URL
                            ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    size: 28,
                    color: Colors.blueGrey,
                  ),
                  label: const Text(
                    'Open Weather Chatbot',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),

                const SizedBox(height: 90),
                const Text("Data Provided By OpenWeatherMap.org"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
