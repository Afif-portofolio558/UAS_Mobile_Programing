import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'notification_service.dart';
import 'beranda.dart';

// 1️⃣ Init utama aplikasi dengan timezone + permission + notif init
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Init timezone (WAJIB untuk notifikasi terjadwal)
  tz.initializeTimeZones();

  // 2️⃣ Init notifikasi + klik handler
  await NotificationService.init((payload) {
    if (payload == 'deadline') {
      print('Notifikasi deadline diklik');
    }
  });

  // 3️⃣ MINTA IZIN NOTIFIKASI (Android 13+)
  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestPermission();

  // 4️⃣ Jalankan aplikasi
  runApp(const MyApp());
}

extension on AndroidFlutterLocalNotificationsPlugin? {
  Future<void> requestPermission() async {}
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTask Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      routes: {
        '/detail': (context) {
          final taskId =
              ModalRoute.of(context)!.settings.arguments as String;
          return TaskDetailById(taskId: int.parse(taskId));
        },
      },
    );
  }
}

/* ===================== LOGIN PAGE ===================== */

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const _validUser = 'admin';
  static const _validPass = '12345';

  Future<void> _handleLogin() async {
    final user = _usernameController.text.trim();
    final pass = _passwordController.text;

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan password harus diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (user != _validUser || pass != _validPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau password salah'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HalamanUtama()),
    );
  }

  Widget _loginLogo(bool isPortrait) {
    final size = isPortrait ? 120.0 : 150.0;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18,
            spreadRadius: 6,
          )
        ],
      ),
      child: const Icon(
        Icons.task_alt,
        size: 70,
        color: Colors.indigo,
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3F51B5), Color(0xFF1A237E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isPortrait ? 24 : 48,
              vertical: 20,
            ),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.08),
                _loginLogo(isPortrait),
                SizedBox(height: screenHeight * 0.05),
                const Text(
                  'MyTask Manager',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kelola tugas Anda dengan mudah',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: screenHeight * 0.06),
                _loginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
          )
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleLogin,
              icon: const Icon(Icons.login),
              label: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Masuk'),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskDetailById extends StatelessWidget {
  final int taskId;
  const TaskDetailById({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tugas')),
      body: Center(child: Text('Menampilkan detail tugas id: $taskId')),
    );
  }
}
