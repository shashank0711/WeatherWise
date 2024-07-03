import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/Utils.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final cityController = TextEditingController();
  String selectedCity = 'Kanpur';
  late Future<Map<String, dynamic>> weatherData;

  @override
  void initState() {
    super.initState();
    weatherData = getCurrentWeather(selectedCity);
  }

  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    try {
      final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey'));

      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw data['message'];
      }

      return data;

      print(data['list'][0]['main']['temp']);
    } catch (e) {
      throw e.toString();
    }
  }

  void updateWeather(String cityName) {
    setState(() {
      selectedCity = cityName;
      weatherData = getCurrentWeather(selectedCity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Weather App',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    weatherData = getCurrentWeather(selectedCity);
                  });
                },
                icon: Icon(Icons.refresh)),
          ],
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              //textformfield to enter the city name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: size.width * 0.4,
                    child: Row(
                      children: [
                        const Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.location_on,
                            size: 30,
                          ),
                        ),
                        Text(
                          selectedCity,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: size.width * .47,
                    child: TextField(
                      controller: cityController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        contentPadding: EdgeInsets.all(15),
                        hintText: 'Enter City...',
                        filled: true,
                        fillColor: Colors.black38,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.black54,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          updateWeather(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: size.height * .02,
              ),

              FutureBuilder(
                future: weatherData,
                builder: (context, snapshot) {
                  // print(snapshot);
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }

                  final data = snapshot.data!;
                  final currentWeatherData = data['list'][0];

                  final currentTemp = (currentWeatherData['main']['temp'] - 273).toStringAsFixed(1);
                  final currentSky = currentWeatherData['weather'][0]['main'];
                  final humidityValue = currentWeatherData['main']['humidity'];
                  final windSpeed = currentWeatherData['wind']['speed'];
                  final pressureValue = currentWeatherData['main']['pressure'];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //main card
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '$currentTemp °C',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * .02,
                                    ),
                                    Icon(
                                      currentSky == 'Clouds' ||
                                              currentSky == 'Rain'
                                          ? Icons.cloud
                                          : Icons.sunny,
                                      size: 65,
                                    ),
                                    SizedBox(
                                      height: size.height * .02,
                                    ),
                                    Text(
                                      '$currentSky',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      //weather forcast card
                      SizedBox(
                        height: size.height * .03,
                      ),
                      const Text(
                        'Hourly Forecast',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: size.height * .015,
                      ),

                      SizedBox(
                        height: size.height * .16,
                        child: ListView.builder(
                            itemCount: 9,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final hourlyForecast =
                                  data['list'][index + 1]['dt_txt'];
                              final hourlySky = data['list'][index + 1]['weather'][0]['main'];
                              final hourlyTemp = (data['list'][index + 1]['main']['temp'] - 273).toStringAsFixed(1);
                              final hourlyTime = DateTime.parse(hourlyForecast);
                              return ForecastBlock(
                                  DateFormat.j().format(hourlyTime),
                                  hourlySky == 'Clouds' || hourlySky == 'Rain'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  hourlyTemp);
                            }),
                      ),

                      //additional informations
                      SizedBox(
                        height: size.height * .06,
                      ),
                      const Text(
                        'Additional Information',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: size.height * .015,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Additional_info_block(
                              Icons.water_drop, 'Humidity', '$humidityValue'),
                          Additional_info_block(
                              Icons.air, 'Wind Speed', '$windSpeed'),
                          Additional_info_block(
                              Icons.beach_access, 'Pressure', '$pressureValue'),
                        ],
                      )
                    ],
                  );
                },
              ),
            ],
          ),
        )));
  }
}
