/// Resumen mínimo que usaremos en la app
class VulnerabilidadModel {
  final String id;
  final DateTime? published;
  final List<String> products; // vendor:product

  VulnerabilidadModel({
    required this.id,
    required this.published,
    required this.products,
  });

  @override
  String toString() =>
      'CVE: $id | published: $published | products: ${products.join(", ")}';
}