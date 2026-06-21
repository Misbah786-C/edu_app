import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'controllers/auth_controller.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_local_storage.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Open the Hive box used for offline course caching before the app starts.
  await CourseLocalStorage.init();
  runApp(const EduApp());
}

class EduApp extends StatelessWidget {
  const EduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        // The provider receives a repository, which wires together the API
  