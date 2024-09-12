import 'package:flutter/material.dart';
import 'package:gym_project_app/pages/login_page.dart';
import 'package:gym_project_app/pages/home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gym_project_app/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  
  const storage = FlutterSecureStorage();
  await storage.write(key: 'access_token', value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiTUVNQkVSIiwic3ViIjoiNTViOTZjYTEtOTM5Ny00ZTU5LTg1YzYtYWZiODk2NzMzZjBhIiwiaWF0IjoxNzI2MTMwNDA5fQ.87m6iBCZBj-mIQixPOjYBO4TW6T8PXu7ROKZXBcjfy8');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym App',
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: _decideInitialRoute(),
    );
  }

  Widget _decideInitialRoute() {
    final apiService = ApiService();
    return apiService.getToken() != null ? const HomePage() : LoginPage();
  }
}
