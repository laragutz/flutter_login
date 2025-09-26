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
            Text('¡Bienvenido, $username!',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Has ingresado correctamente.',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
