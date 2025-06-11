import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myweatherapp/secrets.dart';

class ChatbotService {
  final String openAiApiKey;
  final String weatherApiKey;

  ChatbotService({required this.openAiApiKey, required this.weatherApiKey});

  Future<String> getResponse(String userMessage) async {
    try {
      print('User message: $userMessage');

      final city = await _extractCityWithOpenAI(userMessage);
      if (city == null || city.isEmpty) {
        return "Please mention a valid city in your message.";
      }

      final weatherData = await _fetchWeather(city);
      print('Weather data fetched: $weatherData');

      final temp = weatherData['main']['temp'].toString();
      final humidity = weatherData['main']['humidity'].toString();
      final windSpeed = weatherData['wind']['speed'].toString();
      final description = weatherData['weather'][0]['description'];

      return await _getOpenAiResponse(
        userMessage: userMessage,
        city: city,
        temp: temp,
        humidity: humidity,
        windSpeed: windSpeed,
        description: description,
      );
    } catch (e, st) {
      print('Error caught: $e');
      print('Stack trace: $st');
      return "Sorry, I couldn't fetch the weather info or process your request.";
    }
  }

  Future<String?> _extractCityWithOpenAI(String userMessage) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${Secrets.openAiApiKey}',
    };

    final body = jsonEncode({
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "system",
          "content":
              "Extract only the city name from the user's message. Only return the city name. If not found, return an empty string.",
        },
        {"role": "user", "content": userMessage},
      ],
      "max_tokens": 20,
      "temperature": 0,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final city = data['choices'][0]['message']['content'].trim();
      return city;
    } else {
      print('City extraction failed: ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>> _fetchWeather(String city) async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=5f6098755d39441771decb4ac9b9109c",
    );

    final response = await http.get(url);
    print('Weather API URL: $url');
    print('Weather API Status: ${response.statusCode}');
    print('Weather API Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch weather for $city');
    }
  }

  Future<String> _getOpenAiResponse({
    required String userMessage,
    required String city,
    required String temp,
    required String humidity,
    required String windSpeed,
    required String description,
  }) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $openAiApiKey',
    };

    final body = jsonEncode({
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "system",
          "content": '''
You are a helpful assistant specialized in weather information.
Here is the latest weather data:
City: $city
Temperature: $temp °C
Humidity: $humidity%
Wind Speed: $windSpeed km/h
Description: $description

Use this information to answer questions about the weather in a friendly and human way.
''',
        },
        {"role": "user", "content": userMessage},
      ],
      "max_tokens": 150,
      "temperature": 0.7,
    });

    print('Sending request to OpenAI...');
    final response = await http.post(url, headers: headers, body: body);

    print('OpenAI API status: ${response.statusCode}');
    print('OpenAI API body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final answer = data['choices'][0]['message']['content'];
      return answer.trim();
    } else {
      throw Exception('OpenAI API error: ${response.statusCode}');
    }
  }
}
