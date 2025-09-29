import 'package:flutter/material.dart';
import 'package:flutter_login/auth_service.dart';
import 'package:flutter_login/home_page.dart';
import 'package:flutter_login/home_admin_page.dart';
import 'package:flutter_login/register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  AuthService _authService = AuthService();

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      _authService
          .signIn(_emailController.text, _passwordController.text)
          .then((user) async {
        setState(() {
          _isLoading = false;
        });
        if (user != null) {
          // Forzar refresh del token para obtener custom claims actualizadas
          final idTokenResult = await user.getIdTokenResult(true);
          final claims = idTokenResult.claims ?? {};
          // (Logs de depuración removidos)

          // Aceptar admin como bool true o string 'true'
          final dynamic adminClaim = claims['admin'];
          final bool isAdmin = (adminClaim == true) || (adminClaim is String && adminClaim.toLowerCase() == 'true');

          if (!mounted) return;

          // (SnackBar de rol removido)

          if (isAdmin) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HomeAdminPage(username: user.email ?? 'Administrador'),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HomePage(username: user.email ?? 'Usuario'),
              ),
            );
          }
              //      ScaffoldMessenger.of(context).showSnackBar(
            //const SnackBar(content: Text('Autenticación exitosa')),);
        } else {
          // Mostrar error de autenticación
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error de autenticación')),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(
        decoration: const BoxDecoration(
          // Fondo con imagen en color claro
          gradient: LinearGradient(
            colors: [Color(0xFFFFF5F5), Color(0xFFFFE5E5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.account_circle,
                            size: 60,
                            color: Color(0xFF8B1538), // Color guinda
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Quiz Ciberseguridad',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B1538),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Marco del formulario
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Iniciar Sesión',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B1538),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Input de Email/Usuario
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email o Usuario',
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: Color(0xFF8B1538),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8B1538),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu email o usuario';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Input de Contraseña
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF8B1538),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Color(0xFF8B1538),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8B1538),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Enlace "Olvidé mi contraseña"
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                               onPressed: () {},
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  color: Color(0xFF8B1538),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Botón de Iniciar Sesión
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF8B1538), // Color guinda
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Botón secundario (opcional)
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RegisterPage(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF8B1538),
                              side: const BorderSide(
                                color: Color(0xFF8B1538),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Crear Cuenta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
);
  }
}