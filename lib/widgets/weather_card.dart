import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  _WeatherCardState createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  String _weatherInfo = "Loading...";
  String _temperature = "";
  String _humidity = "";
  String _windSpeed = "";
  String _cityName = "Jakarta";
  bool _isLoading = true;
  bool _hasError = false;

  // API key - sebaiknya simpan di environment variable atau secure storage
  final String apiKey = 'bbd3592bb082a83729b7082f7ad8598a';

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  IconData _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('rain')) return Icons.water_drop;
    if (condition.contains('cloud')) return Icons.cloud;
    if (condition.contains('clear')) return Icons.wb_sunny;
    if (condition.contains('snow')) return Icons.ac_unit;
    if (condition.contains('thunder')) return Icons.flash_on;
    return Icons.cloud_queue;
  }

  Future<void> fetchWeather() async {
    try {
      // Step 1: Get coordinates for Jakarta
      final geoResponse = await http.get(
        Uri.parse('http://api.openweathermap.org/geo/1.0/direct?q=Jakarta&limit=1&appid=$apiKey'),
      );  

      if (geoResponse.statusCode == 200) {
        var locations = json.decode(geoResponse.body);
        if (locations.isNotEmpty) {
          var location = locations[0];
          double lat = location['lat'];
          double lon = location['lon'];

          // Step 2: Get weather data using coordinates
          final weatherResponse = await http.get(
            Uri.parse(
              'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey',
            ),
          );

          if (weatherResponse.statusCode == 200) {
            var data = json.decode(weatherResponse.body);
            setState(() {
              _weatherInfo = data['weather'][0]['description'];
              _temperature = data['main']['temp'].toStringAsFixed(1);
              _humidity = data['main']['humidity'].toString();
              _windSpeed = data['wind']['speed'].toString();
              _cityName = data['name'];
              _isLoading = false;
              _hasError = false;
            });
          } else {
            throw Exception('Failed to load weather data');
          }
        } else {
          throw Exception('Location not found');
        }
      } else {
        throw Exception('Failed to get location coordinates');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print('Error fetching weather: $e'); // For debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 600,
            minHeight: 250,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue[400]!,
                Colors.blue[900]!,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : _hasError
                    ? _buildErrorWidget()
                    : _buildWeatherContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 60,
        ),
        const SizedBox(height: 16),
        const Text(
          'Failed to fetch weather data',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        TextButton(
          onPressed: fetchWeather,
          child: const Text(
            'Retry',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _cityName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Today\'s Weather',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            Icon(
              _getWeatherIcon(_weatherInfo),
              size: 60,
              color: Colors.white,
            ),
          ],
        ),
        Expanded(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_temperature°',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'C',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          _weatherInfo.toUpperCase(),
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white70,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildWeatherDetail(
                Icons.water_drop,
                'Humidity',
                '$_humidity%',
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white24,
            ),
            Expanded(
              child: _buildWeatherDetail(
                Icons.air,
                'Wind Speed',
                '$_windSpeed m/s',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}