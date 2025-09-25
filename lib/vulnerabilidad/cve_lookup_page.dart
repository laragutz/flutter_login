import 'package:flutter/material.dart';
import 'package:flutter_login/vulnerabilidad/vulnerabilidad_model.dart';
import 'vulnerabilidad_service.dart'; // <-- tu servicio

class CveLookupPage extends StatefulWidget {
  const CveLookupPage({super.key});

  @override
  State<CveLookupPage> createState() => _CveLookupPageState();
}

class _CveLookupPageState extends State<CveLookupPage> {
  final _formKey = GlobalKey<FormState>();
  final _cveCtrl = TextEditingController(text: 'CVE-2021-44228');
  final _servicio = VulnerabilidadService();
  Future<VulnerabilidadModel>? _future;
  bool _loading = false;

  // Valida formato CVE básico: CVE-YYYY-NNNN...
  String? _validateCve(String? v) {
    final value = (v ?? '').trim().toUpperCase();
    if (value.isEmpty) return 'Ingresa un ID de CVE';
    final reg = RegExp(r'^CVE-\d{4}-\d{4,7}$');
    if (!reg.hasMatch(value)) return 'Formato inválido. Ej: CVE-2021-44228';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _future = _servicio.fetchVulnerabilidad(_cveCtrl.text.trim().toUpperCase());
    });
    // No await aquí; FutureBuilder manejará el estado
  }

  @override
  void dispose() {
    _cveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consulta CVE (NVD)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cveCtrl,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        labelText: 'ID de CVE',
                        hintText: 'Ej: CVE-2021-44228',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateCve,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _submit,
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<VulnerabilidadModel>(
                future: _future,
                builder: (context, snap) {
                  // sincroniza bandera de carga
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_loading !=
                        (snap.connectionState == ConnectionState.waiting)) {
                      setState(() => _loading =
                          (snap.connectionState == ConnectionState.waiting));
                    }
                  });

                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${snap.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (!snap.hasData) {
                    return const Center(
                      child: Text('Ingresa un CVE y presiona “Buscar”.'),
                    );
                  }

                  final cve = snap.data!;
                  return ListView(
                    children: [
                      Card(
                        child: ListTile(
                          title: Text(cve.id,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'Publicado: ${cve.published ?? 'Desconocido'}'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                  'Productos / tecnologías afectadas (vendor:product)',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              if (cve.products.isEmpty)
                                const Text('No se listaron CPE para este CVE.')
                              else
                                ...cve.products.map((p) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: Text('• $p'),
                                    )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
