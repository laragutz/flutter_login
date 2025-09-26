import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_login/vulnerabilidad/vulnerabilidad_model.dart';

class VulnerabilidadService {
  /// Llama a la API 2.0 de la NVD y devuelve ID, fecha publicada y productos (CPE)
  /// Ej: fetchCveSummary('CVE-2021-44228')
  Future<VulnerabilidadModel> fetchVulnerabilidad(String cveId,
      {String? nvdApiKey}) async {
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
    print(resp.body);

    final Map<String, dynamic> data =
        jsonDecode(resp.body) as Map<String, dynamic>;
    print(data);
    final vulns = (data['vulnerabilities'] as List?) ?? [];
    if (vulns.isEmpty) {
      throw Exception('No se encontró información para $cveId');
    }

    // La estructura de NVD 2.0 trae "vulnerabilities" -> [ { "cve": { ... } } ]
    final cveObj = vulns.first['cve'] as Map<String, dynamic>;
    print(cveObj);
    final id = (cveObj['id'] as String?) ?? cveId;
    print(id);

    // Fecha de publicación (ISO-8601), puede ser null en algunos casos raros
    DateTime? published;
    final pubStr = cveObj['published'] as String?;
    if (pubStr != null) {
      try {
        published = DateTime.parse(pubStr);
      } catch (_) {}
    }
    print(published);

    // Extraer productos afectados desde los CPE en "configurations"
    final products = <String>{};
    final descriptions = (cveObj['descriptions'] as List?) ?? {};
    print(descriptions);
    for (final item in descriptions) {
      products.add((item['value'] as String?) ?? '');
    }

    return VulnerabilidadModel(
      id: id,
      published: published,
      products: products.toList()..sort(),
    );
  }
}
