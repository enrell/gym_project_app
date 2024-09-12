import 'package:flutter/material.dart';
import 'package:gym_project_app/models/gym.dart';
import 'package:gym_project_app/services/gym_service.dart';
import 'package:gym_project_app/components/gym_card.dart';
import 'package:gym_project_app/pages/qr_scanner_page.dart';
import 'package:gym_project_app/services/api_service.dart';

class GymListPage extends StatefulWidget {
  const GymListPage({super.key});

  @override
  State<GymListPage> createState() => GymListPageState();
}

class GymListPageState extends State<GymListPage> {
  final GymService _gymService = GymService();
  final ApiService _apiService = ApiService();
  final List<Gym> _gyms = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  Future<void> _loadGyms({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _gyms.clear();
      });
    }

    if (_currentPage > _totalPages) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _gymService.getGyms(
        page: _currentPage,
        perPage: 20,
      );
      if (mounted) {
        setState(() {
          _gyms.addAll(result['gyms'] as List<Gym>);
          _totalPages = result['total_pages'] as int;
          _currentPage++;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (e.toString().contains('No access token available')) {
          // Handle the case where there's no token (user might need to log in again)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Please log in again.')),
          );
          // Navigate to login page or show login dialog
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load gyms: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _navigateToQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerPage(
          onScanComplete: _performCheckIn,
        ),
      ),
    );
  }

  Future<void> _performCheckIn(String qrCode) async {
    try {
      final result = await _apiService.performCheckIn(qrCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during check-in: ${e.toString()}')),
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
            onPressed: _navigateToQRScanner,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadGyms(refresh: true),
        child: _gyms.isEmpty && !_isLoading
            ? const Center(child: Text('No gyms found'))
            : ListView.builder(
                itemCount: _gyms.length + (_currentPage <= _totalPages ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _gyms.length) {
                    if (_isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      _loadGyms();
                      return const SizedBox.shrink();
                    }
                  }

                  return GymCard(gym: _gyms[index]);
                },
              ),
      ),
    );
  }
}