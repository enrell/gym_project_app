import 'package:gym_project_app/models/gym.dart';
import 'package:gym_project_app/services/api_service.dart';

class GymService {
  final ApiService _apiService = ApiService();

  Future<List<Gym>> getNearbyGyms() async {
    // TODO: Implement actual API call to get nearby gyms
    // For now, we'll return mock data
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return [
      Gym(
        id: '1',
        title: 'Gym A',
        description: 'A great gym near you',
        latitude: -23.550520,
        longitude: -46.633309,
        price: 50.0,
        distance: 1.5,
      ),
      Gym(
        id: '2',
        title: 'Gym B',
        description: 'Another awesome gym',
        latitude: -23.551234,
        longitude: -46.634567,
        price: 60.0,
        distance: 2.3,
      ),
    ];
  }
}