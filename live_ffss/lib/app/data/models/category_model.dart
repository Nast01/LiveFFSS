class CategoryModel {
  late int id;
  late String name;
  late int? ageMin;
  late int? ageMax;
  CategoryModel({
    required this.id,
    required this.name,
    required this.ageMin,
    required this.ageMax,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json["Id"],
      name: json["Nom"],
      ageMin: json["AgeMin"] ?? 0,
      ageMax: json["AgeMax"] ?? 0,
    );
  }
}