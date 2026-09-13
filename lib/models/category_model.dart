class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.isDefault = false,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isDefault: json['default'] as bool? ?? json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'isDefault': isDefault,
    };
  }
}
