import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class RecommandationDetailsPage extends StatefulWidget {
  const RecommandationDetailsPage({super.key});

  @override
  State<RecommandationDetailsPage> createState() =>
      _RecommandationDetailsPageState();
}

class _RecommandationDetailsPageState extends State<RecommandationDetailsPage> {
  List<Map> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final box = await Hive.openBox<Map>('notification_history');
    final now = DateTime.now();

    final allNotifications = box.values.toList().cast<Map>();

    setState(() {
      _notifications = allNotifications.where((notif) {
        final timestampStr = notif['timestamp'];
        if (timestampStr == null) return false;
        final timestamp = DateTime.tryParse(timestampStr);
        if (timestamp == null) return false;
        return now.difference(timestamp).inHours < 24;
      }).toList();

      _notifications.sort(
          (a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));
    });

    // 🔴 Après affichage : marquer comme lus
    for (int i = 0; i < box.length; i++) {
      final notif = box.getAt(i);
      if (notif != null && (notif['isRead'] != true)) {
        final updated = Map<String, dynamic>.from(notif);
        updated['isRead'] = true;
        await box.putAt(i, updated);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Recommandations AI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 37, 100, 84),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text('Aucune notification reçue.'))
          : ListView.builder(
              itemCount: _notifications.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                final title = notif['title'] ?? 'Sans titre';
                final body = notif['body'] ?? 'Pas de contenu';
                final timestamp = DateTime.tryParse(notif['timestamp'] ?? '');
                final isAlert = title.toLowerCase().contains('alerte');

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 194, 196, 194),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: isAlert ? Colors.red : Colors.green,
                          radius: 20,
                          child: const Icon(
                            Icons.notifications,
                            color: Color.fromARGB(255, 243, 244, 244),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(body),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  _formatDate(timestamp),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inDays >= 1) {
      return 'Hier';
    } else if (difference.inHours >= 1) {
      return 'il y a ${difference.inHours}h';
    } else if (difference.inMinutes >= 1) {
      return 'il y a ${difference.inMinutes}min';
    } else {
      return 'À l’instant';
    }
  }
}
