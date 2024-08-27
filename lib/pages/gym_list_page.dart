import 'package:flutter/material.dart';
import 'package:gym_project_app/models/gym.dart';
import 'package:gym_project_app/services/gym_service.dart';
import 'package:gym_project_app/pages/gym_detail_page.dart';
import 'package:gym_project_app/pages/qr_scanner_page.dart';

class GymListPage extends StatefulWidget {
  const GymListPage({super.key});

  @override
  State<GymListPage> createState() => GymListPageState();
}

class GymListPageState extends State<GymListPage> {
  final GymService _gymService = GymService();
  List<Gym> _gyms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  Future<void> _loadGyms() async {
    try {
      final gyms = await _gymService.getNearbyGyms();
      setState(() {
        _gyms = gyms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load gyms')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academias Próximas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRScannerPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _gyms.length,
              itemBuilder: (context, index) {
                final gym = _gyms[index];
                return ListTile(
                  title: Text(gym.title),
                  subtitle: Text(gym.description ?? ''),
                  trailing: Text('${gym.distance.toStringAsFixed(2)} km'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GymDetailPage(gym: gym),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}