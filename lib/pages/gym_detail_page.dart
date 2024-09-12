import 'package:flutter/material.dart';
import 'package:gym_project_app/models/gym.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gym_project_app/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gym_project_app/pages/qr_scanner_page.dart';

class GymDetailPage extends StatefulWidget {
  final Gym gym;

  const GymDetailPage({super.key, required this.gym});

  @override
  State<GymDetailPage> createState() => _GymDetailPageState();
}

class _GymDetailPageState extends State<GymDetailPage> {
  final ApiService _apiService = ApiService();
  late Gym _gym;
  String _address = 'Carregando...';
  static const int _descriptionMaxLines = 3;
  int _remainingCheckins = 0;

  @override
  void initState() {
    super.initState();
    _gym = widget.gym;
    _loadGymDetails();
    _getAddress();
    _getRemainingCheckins();
  }

  Future<void> _loadGymDetails() async {
    try {
      final updatedGym = await _apiService.getGymDetails(_gym.id);
      if (updatedGym != null) {
        setState(() {
          _gym = updatedGym;
        });
      }
      // Se updatedGym for null, não fazemos nada, mantendo os dados existentes
    } catch (e) {
      print('Erro ao carregar detalhes da academia: $e');
      // Removemos a SnackBar para não mostrar mensagem ao usuário quando não há atualizações
    }
  }

  Future<void> _getAddress() async {
    try {
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${_gym.latitude}&lon=${_gym.longitude}&zoom=18&addressdetails=1'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        
        String formattedAddress = '';
        
        if (address['road'] != null) {
          formattedAddress += '${address['road']}';
          if (address['house_number'] != null) {
            formattedAddress += ', ${address['house_number']}';
          }
          formattedAddress += '\n';
        }
        
        if (address['postcode'] != null) {
          formattedAddress += '${address['postcode']} ';
        }
        
        if (address['city'] != null) {
          formattedAddress += address['city'];
        } else if (address['town'] != null) {
          formattedAddress += address['town'];
        } else if (address['village'] != null) {
          formattedAddress += address['village'];
        }
        
        setState(() {
          _address = formattedAddress.isNotEmpty ? formattedAddress : 'Endereço não disponível';
        });
      } else {
        setState(() {
          _address = 'Não foi possível obter o endereço';
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Erro ao obter o endereço';
      });
    }
  }

  void _navigateToQRScanner() {
    if (_remainingCheckins > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRScannerPage(
            onScanComplete: _performCheckIn,
          ),
        ),
      );
    } else {
      _showNoCheckInsAvailableDialog();
    }
  }

  void _showNoCheckInsAvailableDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sem check-ins disponíveis'),
          content: const Text('Você não tem mais check-ins disponíveis hoje. Tente novamente amanhã.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performCheckIn(String qrCode) async {
    try {
      final result = await _apiService.performCheckIn(qrCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      setState(() {
        _remainingCheckins = result['remainingCheckIns'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro durante o check-in: ${e.toString()}')),
      );
    }
  }

  String _formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Não disponível';
    }
    
    String numericPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numericPhone.length == 11) {
      return '(${numericPhone.substring(0, 2)}) ${numericPhone.substring(2, 3)} ${numericPhone.substring(3, 7)}-${numericPhone.substring(7)}';
    } else if (numericPhone.length == 10) {
      return '(${numericPhone.substring(0, 2)}) ${numericPhone.substring(2, 6)}-${numericPhone.substring(6)}';
    } else {
      return phone;
    }
  }

  void _showFullDescription() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Container(
              height: 5,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Descrição',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _gym.description ?? 'Não disponível',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _gym.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _gym.imageUrl ?? 'https://via.placeholder.com/400x200?text=Gym+Image',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Localização',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(_gym.latitude, _gym.longitude),
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 40.0,
                                height: 40.0,
                                point: LatLng(_gym.latitude, _gym.longitude),
                                child: Icon(Icons.location_on, color: theme.primaryColor, size: 40.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildRemainingCheckinsInfo(theme),
                  const SizedBox(height: 24),
                  _buildDescriptionSection(theme),
                  _buildInfoSection('Telefone', _formatPhoneNumber(_gym.phone), Icons.phone, theme),
                  _buildInfoSection('Endereço', _address, Icons.location_on, theme),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToQRScanner,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Check In'),
        backgroundColor: _remainingCheckins > 0 ? theme.primaryColor : Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildRemainingCheckinsInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            _remainingCheckins > 0
                ? 'Check-ins restantes hoje: $_remainingCheckins'
                : 'Sem check-ins restantes hoje',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, size: 24, color: theme.primaryColor),
            const SizedBox(width: 16),
            Text(
              'Descrição',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _gym.description ?? 'Não disponível',
          style: theme.textTheme.bodyMedium,
          maxLines: _descriptionMaxLines,
          overflow: TextOverflow.ellipsis,
        ),
        if ((_gym.description ?? '').length > _descriptionMaxLines * 40)
          TextButton(
            onPressed: _showFullDescription,
            child: const Text('Mostrar mais'),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: theme.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getRemainingCheckins() async {
    try {
      final remainingCheckins = await _apiService.getRemainingCheckins(_gym.id);
      setState(() {
        _remainingCheckins = remainingCheckins;
      });
    } catch (e) {
      print('Erro ao obter check-ins restantes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível obter o número de check-ins restantes')),
      );
      setState(() {
        _remainingCheckins = 0;
      });
    }
  }
}
