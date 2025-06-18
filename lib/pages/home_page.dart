import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hasad_app/auth/login_page.dart';
import 'package:hasad_app/pages/drawer_widget.dart';
import 'package:hasad_app/pages/history_page.dart';
import 'package:hasad_app/pages/meteo_page.dart';
import 'package:hasad_app/pages/maladie_page.dart';
import 'package:hasad_app/pages/recommandation_Details.dart';
import 'package:hive/hive.dart';
import '../services/weather_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hasad_app/widgets/language_picker_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  Map<String, dynamic>? weatherData;
  Map<String, dynamic> get main => weatherData?["main"] ?? {};
  Map<String, dynamic> get weather => (weatherData?["weather"]?[0] ?? {});

  @override
  void initState() {
    super.initState();
    loadWeather();
    //notification
    _loadNotificationCount();
  }

  Future<void> loadWeather() async {
    try {
      //final data = await WeatherService.getOpenWeatherData("Nouakchott");
      final data =
          await WeatherService.getOpenWeatherData("Bordj Bou Arreridj");
      setState(() {
        weatherData = data;
      });
    } catch (e) {
      print("Erreur de récupération météo : $e");
    }
  }

//notification count
  int _notificationCount = 0;

  Future<void> _loadNotificationCount() async {
    final box = await Hive.openBox<Map>('notification_history');
    final now = DateTime.now();

    final unread = box.values.where((notif) {
      final timestampStr = notif['timestamp'];
      final isRead = notif['isRead'] ?? false;

      if (timestampStr == null || isRead == true) return false;

      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp == null) return false;

      return now.difference(timestamp).inHours < 24;
    });

    setState(() {
      _notificationCount = unread.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: DrawerWidget(
        user: user,
        onLogout: () async {
          await FirebaseAuth.instance.signOut();
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        },
        onSelectPage: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 100, 84),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const LanguagePickerDialog(),
              );
            },
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none, color: Colors.white),
                if (_notificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecommandationDetailsPage(),
                ),
              );
              _loadNotificationCount(); // Recharge après retour
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _getSelectedPage(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 100, 137, 137),
              blurRadius: 7,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: currentIndex,
          selectedItemColor: Color.fromARGB(255, 44, 120, 101),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
          onTap: (index) {
            setState(() => currentIndex = index);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 0 ? Icons.home : Icons.home_outlined,
              ),
              label: AppLocalizations.of(context)!.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 1
                    ? Icons.camera_alt
                    : Icons.camera_alt_outlined,
              ),
              label: AppLocalizations.of(context)!.disease,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 2 ? Icons.cloud : Icons.cloud_outlined,
              ),
              label: AppLocalizations.of(context)!.weather,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSelectedPage() {
    switch (currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const MaladiePage();
      case 2:
        return const MeteoPage();
      default:
        return const SizedBox();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.weatherConditions,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF173F35),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
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
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(2, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: weatherData == null
                  ? const Center(
                      child: SpinKitThreeBounce(
                        color: Colors.white,
                        size: 40,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${weatherData?["name"] ?? "Unknown"}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getFormattedDate(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              _getWeatherIcon(weather["main"] ?? ""),
                              color: Colors.white,
                              size: 40,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${main["temp"]?.toInt() ?? "--"}°",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${weather["description"] ?? "--"}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "${main["temp_min"]?.toInt() ?? "--"}°C / ${main["temp_max"]?.toInt() ?? "--"}°C",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              "C",
                              style: TextStyle(
                                color: Colors.white,
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
            Text(
              AppLocalizations.of(context)!.smartSupport,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF173F35),
              ),
            ),
            const SizedBox(height: 6),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _customCard(
                      title: AppLocalizations.of(context)!.recommendations,
                      description:
                          AppLocalizations.of(context)!.getSmartSuggestions,
                      imagePath: "assets/ai.png",
                      color: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const RecommandationDetailsPage()),
                        );
                      },
                    ),
                    _customCard(
                      title: AppLocalizations.of(context)!.diseaseDetection,
                      description:
                          AppLocalizations.of(context)!.identifyPlantProblems,
                      imagePath: "assets/maladie.png",
                      color: Colors.white,
                      onTap: () {
                        setState(() => currentIndex = 1);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _customCard(
                      title: AppLocalizations.of(context)!.history,
                      description:
                          AppLocalizations.of(context)!.viewYourPastData,
                      imagePath: "assets/historique.png",
                      color: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HistoryPage()),
                        );
                      },
                    ),
                    _customCard(
                      title: AppLocalizations.of(context)!.weather,
                      description:
                          AppLocalizations.of(context)!.checkWeatherInfo,
                      imagePath: "assets/weather.png",
                      color: Colors.white,
                      onTap: () {
                        setState(() => currentIndex = 2);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _customCard({
    required String title,
    required String description,
    required String imagePath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(30),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 142, 155, 147),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              height: 43,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF173F35)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
