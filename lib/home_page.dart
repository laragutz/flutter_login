import 'package:flutter/material.dart';
import 'package:flutter_login/vulnerabilidad/cve_lookup_page.dart';

class HomePage extends StatelessWidget {
  final String username;
  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Regresa a la pantalla de login (asegúrate de registrar la ruta '/login'
              // o reemplaza con la navegación a tu LoginPage)
              //Navigator.pushReplacementNamed(context, '/login_page');
              Navigator.pop(context);
            },
          ),
                    IconButton(
            icon: const Icon(Icons.security),
            onPressed: () {
              // Regresa a la pantalla de login (asegúrate de registrar la ruta '/login'
              // o reemplaza con la navegación a tu LoginPage)
              //Navigator.pushReplacementNamed(context, '/login_page');
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => CveLookupPage()));
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 48,
              child: Text(_initials(username),
                  style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(height: 16),
            Text(_getGreeting(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('¡Bienvenido, $username!',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Has ingresado correctamente.',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Text(
                '¡Que tengas un excelente día! 🌟',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '¡Buenos días!';
    } else if (hour < 18) {
      return '¡Buenas tardes!';
    } else {
      return '¡Buenas noches!';
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
