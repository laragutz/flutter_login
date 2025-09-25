import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_login/vulnerabilidad/vulnerabilidad_model.dart';

class VulnerabilidadService {
  /// Llama a la API 2.0 de la NVD y devuelve ID, fecha publicada y productos (CPE)
/// Ej: fetchCveSummary('CVE-2021-44228')
Future<VulnerabilidadModel> fetchVulnerabilidad(String cveId, {String? nvdApiKey}) async {
  // Endpoint NVD 2.0 (cveId como query param)
  final uri = Uri.https(
    'services.nvd.nist.gov',
    '/rest/json/cves/2.0',
    {'cveId': cveId},
  );

  // Cabeceras (el apiKey es opcional para bajo volumen)
  final headers = <String, String>{
    if (nvdApiKey != null && nvdApiKey.isNotEmpty) 'apiKey': nvdApiKey,
    'Accept': 'application/json',
  };

  final resp = await http.get(uri, headers: headers);
  if (resp.statusCode != 200) {
    throw Exception('NVD API error ${resp.statusCode}: ${resp.body}');
  }

  final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;
  final vulns = (data['vulnerabilities'] as List?) ?? [];
  if (vulns.isEmpty) {
    throw Exception('No se encontró información para $cveId');
  }

  // La estructura de NVD 2.0 trae "vulnerabilities" -> [ { "cve": { ... } } ]
  final cveObj = vulns.first['cve'] as Map<String, dynamic>;
  final id = (cveObj['id'] as String?) ?? cveId;

  // Fecha de publicación (ISO-8601), puede ser null en algunos casos raros
  DateTime? published;
  final pubStr = cveObj['published'] as String?;
  if (pubStr != null) {
    try {
      published = DateTime.parse(pubStr);
    } catch (_) {}
  }

  // Extraer productos afectados desde los CPE en "configurations"
  final products = <String>{};
  final configurations = (cveObj['configurations'] as Map?) ?? {};
  final nodes = (configurations['nodes'] as List?) ?? [];

  for (final node in nodes) {
    final matchList = (node['cpeMatch'] as List?) ?? [];
    for (final match in matchList) {
      // En NVD 2.0 normalmente se usa "criteria" (antes: "cpe23Uri")
      final criteria = (match['criteria'] ?? match['cpe23Uri']) as String?;
      if (criteria == null) continue;

      // Ejemplo de CPE 2.3: cpe:2.3:a:apache:log4j:2.14.1:*:*:*:*:*:*:*
      // Formato: cpe:2.3:<part>:<vendor>:<product>:<version>:...
      final parts = criteria.split(':');
      if (parts.length >= 5 && parts[0] == 'cpe' && parts[1] == '2.3') {
        final vendor = parts[3];
        final product = parts[4];
        // Guardamos vendor:product (sin versión) para un listado compacto
        products.add('$vendor:$product');
      }
    }
  }

  return VulnerabilidadModel(
    id: id,
    published: published,
    products: products.toList()..sort(),
  );
}
}