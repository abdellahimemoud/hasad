import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MeteoPage extends StatefulWidget {
  const MeteoPage({super.key});

  @override
  State<MeteoPage> createState() => _MeteoPageState();
}

class _MeteoPageState extends State<MeteoPage> {
  Map<String, dynamic>? weatherData;
  Map<String, dynamic>? forecastData;
  Map<String, dynamic>? tomorrowData;

  List<dynamic>? forecastList;

  double? soilMoisture;

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Map<String, dynamic>? oneCallData;

  Future<void> loadWeather() async {
    try {
      final data = await WeatherService.getOpenWeatherData("Nouakchott");
      final lat = data["coord"]["lat"];
      final lon = data["coord"]["lon"];
      final soil = await WeatherService.getSoilMoisture(lat, lon);
      final forecast =
          await WeatherService.getForecastFromForecastApi("Nouakchott");
      final tomorrow = await WeatherService.getTomorrowData(lat, lon);

      setState(() {
        weatherData = data;
        soilMoisture = soil;
        forecastList = forecast;
        tomorrowData = tomorrow;
      });
    } catch (e) {
      print("Erreur de récupération météo : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final main = weatherData?["main"];
    final wind = weatherData?["wind"];
    final weather = weatherData?["weather"]?[0];
    final rain = weatherData?["rain"]?["1h"] ?? 0.0;
    final snow = weatherData?["snow"]?["1h"] ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: weatherData == null
          ? const Center(
              child: SpinKitThreeBounce(
                  color: Color.fromARGB(255, 37, 100, 84), size: 40))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _currentWeather(main, weather),
                const SizedBox(height: 16),
                _sectionTitle(AppLocalizations.of(context)!.currentConditions),
                _infoGrid([
                  _infoCard(AppLocalizations.of(context)!.feelsLike,
                      "${main["feels_like"]}°C", Icons.thermostat),
                  _infoCard(AppLocalizations.of(context)!.humidity,
                      "${main["humidity"]}%", Icons.water_drop),
                  _infoCard(AppLocalizations.of(context)!.wind,
                      "${wind["speed"]} km/h", Icons.air),
                  _infoCard(AppLocalizations.of(context)!.pressure,
                      "${main["pressure"]} hPa", Icons.speed),
                ]),
                const SizedBox(height: 16),
                _sectionTitle(AppLocalizations.of(context)!.precipitation),
                _infoGrid([
                  _infoCard(AppLocalizations.of(context)!.rain, "$rain mm",
                      Icons.water),
                  _infoCard(AppLocalizations.of(context)!.snow, "$snow mm",
                      Icons.ac_unit),
                  _infoCard(AppLocalizations.of(context)!.riskOfRain,
                      "${_getRainChance()}%", Icons.grain),
                  _infoCard("Accum. 24h", "-- mm", Icons.house),
                ]),
                const SizedBox(height: 16),
                _sectionTitle(AppLocalizations.of(context)!.agrIndicators),
                _infoGrid([
                  _infoCard(
                      AppLocalizations.of(context)!.indiceUv,
                      "${tomorrowData?["uvIndex"]?.toStringAsFixed(1) ?? "--"}",
                      Icons.wb_sunny),
                  _infoCard(
                      AppLocalizations.of(context)!.soilMoisture,
                      "${soilMoisture?.toStringAsFixed(1) ?? "--"}%",
                      Icons.eco),
                  _infoCard(
                      AppLocalizations.of(context)!.dewPoint,
                      "${tomorrowData?["dewPoint"]?.toStringAsFixed(1) ?? "--"}°C",
                      Icons.opacity),
                  _infoCard(
                      AppLocalizations.of(context)!.humidity,
                      "${tomorrowData?["humidity"]?.toStringAsFixed(0) ?? "--"}%",
                      Icons.grass),
                ]),
                const SizedBox(height: 16),
                _sectionTitle(AppLocalizations.of(context)!.cultureCondit),
                _infoGrid([
                  _infoCard(AppLocalizations.of(context)!.gdd, "--",
                      Icons.device_thermostat),
                  _infoCard(
                    AppLocalizations.of(context)!.evapotranspiration,
                    "${tomorrowData?["evapotranspiration"]?.toStringAsFixed(1) ?? "--"} mm",
                    Icons.invert_colors,
                  ),
                  _infoCard(AppLocalizations.of(context)!.lunarPhase,
                      AppLocalizations.of(context)!.fullMoon, Icons.nightlight),
                  _infoCard(
                    AppLocalizations.of(context)!.visbility,
                    "${weatherData?["visibility"] != null ? (weatherData!["visibility"] / 1000).toStringAsFixed(1) : "--"} km",
                    Icons.visibility,
                  ),
                ]),
                const SizedBox(height: 16),
                _sectionTitle(AppLocalizations.of(context)!.previsionHor),
                _hourlyForecast(),
                const SizedBox(height: 16),
                _sectionTitle(AppLocalizations.of(context)!.previsionFiveDays),
                _dailyForecast(),
              ],
            ),
    );
  }

  String _getRainChance() {
    return (weatherData?["clouds"]?["all"] ?? 0).toString();
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Color.fromARGB(255, 45, 137, 114)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _infoGrid(List<Widget> children) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: children,
    );
  }

  Widget _currentWeather(dynamic main, dynamic weather) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF173F35),
            Color.fromARGB(255, 85, 128, 165),
            Color.fromARGB(255, 56, 161, 135),
            Color.fromARGB(255, 49, 178, 184),
            Color(0xFF173F35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
              color: Color.fromARGB(255, 37, 100, 84),
              blurRadius: 8,
              offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Text("Météo à ${weatherData?["name"] ?? "inconnue"}",
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(_getFormattedDate(),
              style: const TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 20),
          Icon(
            _getWeatherIcon(weather["main"] ?? ""),
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text("${main["temp"]}°C",
              style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text("${weather["description"]}",
              style: const TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _hourlyForecast() {
    if (forecastList == null || forecastList!.isEmpty) {
      return const Center(child: Text("Aucune prévision horaire disponible"));
    }

    final now = DateTime.now();

    final upcoming = forecastList!
        .where((entry) {
          final date = DateTime.parse(entry["dt_txt"]).toLocal();
          return date.isAfter(now);
        })
        .take(8)
        .toList();

    if (upcoming.isEmpty) {
      return const Center(child: Text("Aucune donnée horaire à venir"));
    }

    return SizedBox(
      height: 140, // Hauteur ajustée
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: upcoming.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final data = upcoming[index];
          final date = DateTime.parse(data["dt_txt"]).toLocal();
          final hour = "${date.hour.toString().padLeft(2, '0')}:00";
          final temp = "${data["main"]["temp"].round()}°C";
          final rain = "${((data["pop"] ?? 0.0) * 100).round()}%";
          final iconCode = data["weather"][0]["icon"];

          return Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                    color: Color.fromARGB(255, 37, 100, 84), blurRadius: 0.1)
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  hour,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Image.network(
                  "https://openweathermap.org/img/wn/$iconCode@2x.png",
                  width: 28,
                  height: 28,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.cloud, color: Colors.grey, size: 28),
                ),
                Text(
                  temp,
                  style: const TextStyle(fontSize: 14),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.grain,
                        size: 12, color: Color.fromARGB(255, 45, 137, 114)),
                    const SizedBox(width: 2),
                    Text(
                      rain,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 45, 137, 114)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dailyForecast() {
    if (forecastList == null) {
      return const Text("Aucune donnée disponible");
    }

    // Grouper les données de forecast par jour (yyyy-MM-dd)
    Map<String, List<dynamic>> dailyGroups = {};

    for (var entry in forecastList!) {
      final date = DateTime.parse(entry["dt_txt"]);
      final key = "${date.year}-${date.month}-${date.day}";
      dailyGroups.putIfAbsent(key, () => []).add(entry);
    }

    final today = DateTime.now();
    final days = dailyGroups.entries
        .where((e) {
          final date = DateTime.parse(e.value.first["dt_txt"]);
          return date.day != today.day || date.month != today.month;
        })
        .take(5) // Max 5 jours de prévision
        .toList();

    return Column(
      children: days.map((data) {
        final entries = data.value;

        final date = DateTime.parse(entries.first["dt_txt"]);
        final dayName = [
          AppLocalizations.of(context)!.sunday,
          AppLocalizations.of(context)!.monday,
          AppLocalizations.of(context)!.tuesday,
          AppLocalizations.of(context)!.wednesday,
          AppLocalizations.of(context)!.thursday,
          AppLocalizations.of(context)!.friday,
          AppLocalizations.of(context)!.saturday
        ][date.weekday % 7];

        final min = entries
            .map((e) => e["main"]["temp_min"] as num)
            .reduce((a, b) => a < b ? a : b)
            .round();
        final max = entries
            .map((e) => e["main"]["temp_max"] as num)
            .reduce((a, b) => a > b ? a : b)
            .round();
        final iconCode = entries.first["weather"][0]["icon"];
        final rainChance =
            ((entries.map((e) => e["pop"] ?? 0.0).reduce((a, b) => a + b) /
                        entries.length) *
                    100)
                .round();

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Image.network(
                "https://openweathermap.org/img/wn/$iconCode@2x.png",
                width: 40),
            title: Text(dayName),
            subtitle: Text("Min: $min° / Max: $max°"),
            trailing: Text("$rainChance%",
                style:
                    const TextStyle(color: Color.fromARGB(255, 45, 137, 114))),
          ),
        );
      }).toList(),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final jours = [
      AppLocalizations.of(context)!.sunday,
      AppLocalizations.of(context)!.monday,
      AppLocalizations.of(context)!.tuesday,
      AppLocalizations.of(context)!.wednesday,
      AppLocalizations.of(context)!.thursday,
      AppLocalizations.of(context)!.friday,
      AppLocalizations.of(context)!.saturday
    ];
    final mois = [
      AppLocalizations.of(context)!.january,
      AppLocalizations.of(context)!.february,
      AppLocalizations.of(context)!.mars,
      AppLocalizations.of(context)!.april,
      AppLocalizations.of(context)!.may,
      AppLocalizations.of(context)!.june,
      AppLocalizations.of(context)!.july,
      AppLocalizations.of(context)!.august,
      AppLocalizations.of(context)!.september,
      AppLocalizations.of(context)!.october,
      AppLocalizations.of(context)!.november,
      AppLocalizations.of(context)!.december
    ];

    String jourNom = jours[now.weekday % 7];
    String moisNom = mois[now.month - 1];
    return "$jourNom ${now.day} $moisNom";
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.bolt;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
        return Icons.blur_on;
      case 'drizzle':
        return Icons.grain;
      default:
        return Icons.help_outline;
    }
  }
}
