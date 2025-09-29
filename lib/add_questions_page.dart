import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddQuestionsPage extends StatefulWidget {
  const AddQuestionsPage({Key? key}) : super(key: key);

  @override
  State<AddQuestionsPage> createState() => _AddQuestionsPageState();
}

class _AddQuestionsPageState extends State<AddQuestionsPage> {
  final _formKey = GlobalKey<FormState>();
  final _questionCtrl = TextEditingController();
  final _correctCtrl = TextEditingController();
  final _wrong1Ctrl = TextEditingController();
  final _wrong2Ctrl = TextEditingController();
  bool _isSaving = false;

  // Ajusta estas constantes a tu backend Laravel
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  static const String _questionsEndpoint = '/questions';

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final uri = Uri.parse('$_baseUrl$_questionsEndpoint');
      final body = {
        'question': _questionCtrl.text.trim(),
        'correct_answer': _correctCtrl.text.trim(),
        'wrong_answer_1': _wrong1Ctrl.text.trim(),
        'wrong_answer_2': _wrong2Ctrl.text.trim(),
        // Si tu backend requiere un campo de categoría/quiz_id, agrégalo aquí.
        // 'quiz_id': 1,
      };

      final resp = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // Si usas autenticación JWT/Bearer agrega aquí el token:
          // 'Authorization': 'Bearer TU_TOKEN',
        },
        body: jsonEncode(body),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pregunta guardada correctamente')),
        );
        _questionCtrl.clear();
        _correctCtrl.clear();
        _wrong1Ctrl.clear();
        _wrong2Ctrl.clear();
      } else {
        String msg = 'Error al guardar (${resp.statusCode})';
        try {
          final data = jsonDecode(resp.body);
          if (data is Map && data['message'] is String) {
            msg = data['message'];
          }
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de red: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _correctCtrl.dispose();
    _wrong1Ctrl.dispose();
    _wrong2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar preguntas'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Nueva pregunta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _questionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Pregunta',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa la pregunta'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _correctCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Respuesta correcta',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa la respuesta correcta'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _wrong1Ctrl,
                  decoration: const InputDecoration(
                    labelText: 'Opción incorrecta 1',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa una opción incorrecta'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _wrong2Ctrl,
                  decoration: const InputDecoration(
                    labelText: 'Opción incorrecta 2',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa una opción incorrecta'
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: const Icon(Icons.save),
                  label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
