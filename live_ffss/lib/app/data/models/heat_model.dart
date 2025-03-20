class HeatModel {
  late int id;
  late String name;
  late bool done;
  late int number;

  HeatModel({
    required this.id,
    required this.name,
    required this.done,
    required this.number,
  });

  factory HeatModel.fromJson(Map<String, dynamic> json) {
    HeatModel heatModel = HeatModel(
      id: json["Id"],
      name: json["Nom"],
      done: json["Fini"],
      number:
          json["Numero"] is String ? int.parse(json["Numero"]) : json["Numero"],
    );

    final results = json["resultats"];

    return heatModel;
    // return HeatModel(
    //   id: json["Id"],
    //   name: json["Nom"],
    //   done: json["Fini"],
    //   number:
    //   json["Numero"] is String ? int.parse(json["Numero"]) : json["Numero"],
    // );
  }
}
