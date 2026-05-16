class CategoryModel {
  final String id;
  final String category;
  final List<String> situations;

  CategoryModel({
    required this.id,
    required this.category,
    required this.situations,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      category: json['category'] ?? '',
      situations: List<String>.from(json['situations'] ?? []),
    );
  }
}
