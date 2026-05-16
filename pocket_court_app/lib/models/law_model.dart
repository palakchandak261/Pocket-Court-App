class LawModel {
  final String id;
  final String category;
  final String situation;
  final String act;
  final String section;
  final String fine;
  final String article;

  LawModel({
    required this.id,
    required this.category,
    required this.situation,
    required this.act,
    required this.section,
    required this.fine,
    required this.article,
  });

  Map<String, dynamic> toJson() => {
        '_id': id,
        'category': category,
        'situation': situation,
        'act': act,
        'section': section,
        'fine': fine,
        'article': article,
      };

  factory LawModel.fromJson(Map<String, dynamic> json) {
    return LawModel(
      id: json['_id'] ?? '',
      category: json['category'] ?? '',
      situation: json['situation'] ?? '',
      act: json['act'] ?? '',
      section: json['section'] ?? '',
      fine: json['fine'] ?? 'N/A',
      article: json['article'] ?? 'N/A',
    );
  }
}
