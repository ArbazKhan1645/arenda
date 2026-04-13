class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final String icon;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CategoryEntity && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
