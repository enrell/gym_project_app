import 'package:flutter/material.dart';
import 'package:gym_project_app/components/gym_card.dart';
import 'package:gym_project_app/models/gym.dart';
import 'package:gym_project_app/services/gym_service.dart';
import 'package:gym_project_app/services/api_service.dart';
import 'package:gym_project_app/pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GymService _gymService = GymService();
  final ApiService _apiService = ApiService();
  final List<Gym> _gyms = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  Future<void> _loadGyms({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _gyms.clear();
        _errorMessage = '';
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
      setState(() {
        _gyms.addAll(result['gyms'] as List<Gym>);
        _totalPages = result['total_pages'] as int;
        _currentPage++;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading gyms: $e';
      });
      print('Error loading gyms: $e');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Tem certeza que deseja sair?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sair'),
              onPressed: () {
                _performLogout();
              },
            ),
          ],
        );
      },
    );
  }

  void _performLogout() {
    _apiService.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academias Próximas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadGyms(refresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage, textAlign: TextAlign.center),
              ElevatedButton(
                onPressed: () => _loadGyms(refresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_gyms.isEmpty && !_isLoading) {
      return const Center(child: Text('Nenhuma academia encontrada'));
    }

    return ListView.builder(
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
    );
  }
}