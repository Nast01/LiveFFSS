import 'package:live_ffss/app/data/models/entry_model.dart';
import 'package:live_ffss/app/data/models/result_model.dart';

class LiveResultModel {
  late int id;
  late String number;
  late EntryModel? entry;
  late ResultModel? result;

  LiveResultModel({
    required this.id,
    required this.number,
    this.entry,
    this.result,
  });

  factory LiveResultModel.fromJson(Map<String, dynamic> json) {
    return LiveResultModel(
      id: json['Id'],
      number: json['Numero'] ?? '',
      entry: json['Engagement'] != null
          ? EntryModel.fromJson(json['Engagement'])
          : null,
      result: json['Resultat'] != null
          ? ResultModel.fromJson(json['Resultat'])
          : null,
    );
  }

  // Helper method to get current rank from result if available
  int? get currentRank => result?.rank;

  // Helper method to get current time from result if available
  int? get currentTime => result?.time;

  // Helper method to get formatted time from result if available
  String? get currentTimeLabel => result?.timeLabel;

  // Helper method to check if result is valid
  bool get hasValidResult => result?.isValid == true;

  // Helper method to check if result is disqualified
  bool get isDisqualified => result?.isDisqualified == true;

  // Copy method for updating the live result
  LiveResultModel copyWith({
    int? id,
    String? number,
    EntryModel? entry,
    ResultModel? result,
    bool? isTemporary,
    DateTime? lastUpdated,
  }) {
    return LiveResultModel(
      id: id ?? this.id,
      number: number ?? this.number,
      entry: entry ?? this.entry,
      result: result ?? this.result,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiveResultModel && other.id == id && other.number == number;
  }

  @override
  int get hashCode => id.hashCode ^ number.hashCode;

  @override
  String toString() {
    return 'LiveResultModel(id: $id, number: $number, rank: $currentRank)';
  }
}
