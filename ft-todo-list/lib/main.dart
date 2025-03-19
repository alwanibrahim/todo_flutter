import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/provider/category_provider.dart';
import 'package:image/provider/label_provider.dart';
import 'package:image/provider/notification_service.dart';
import 'package:image/screens/register_page.dart';
import 'package:provider/provider.dart';
import 'package:image/provider/provider_auth.dart';
import 'package:image/provider/todo_provider.dart';
import 'package:image/screens/home_page.dart';
import 'package:image/screens/login_page.dart';
import 'package:image/api/shared_preferences_service.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // ✅ Pastikan binding Flutter diinisialisasi
  await dotenv.load(fileName: ".env"); // ✅ Load variabel lingkungan
    await NotificationService.init(); // Inisialisasi Notifikasi
    await AwesomeNotifications().initialize(
    'resource://drawable/ic_launcher', // Ganti dengan ikon notifikasi
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notifikasi sederhana',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      )
    ],
  );


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider()), // ✅ Provider untuk autentikasi
        ChangeNotifierProvider(
            create: (_) => CategoryProvider()), // ✅ Provider untuk autentikasi
        ChangeNotifierProvider(
            create: (_) => LabelProvider()), // ✅ Provider untuk autentikasi
        ChangeNotifierProvider(
            create: (_) => TodoProvider()..getTodos()), // ✅ Provider untuk task
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Flutter Login',
        initialRoute: '/',
        routes: {
          '/': (context) => LoginForm(),
          '/home': (context) => HomePage(),
          '/register': (context) => RegisterScreen(),
        },
      ),
    );
  }
}
