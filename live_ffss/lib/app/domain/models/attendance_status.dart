/// Marshalling presence of an engaged athlete. Local to the app — the FFSS API
/// has no presence endpoint — and persisted per race by `AttendanceService`.
enum AttendanceStatus { waiting, present, absent }

extension AttendanceStatusCodec on AttendanceStatus {
  String get storageValue => name;
}

/// Decodes a stored value. Anything unrecognised — an older build's wording, a
/// hand-edited payload — degrades to [AttendanceStatus.waiting], which is also
/// the default for an athlete who was never pointed.
AttendanceStatus attendanceStatusFromStorage(Object? raw) =>
    AttendanceStatus.values.firstWhere(
      (s) => s.name == raw,
      orElse: () => AttendanceStatus.waiting,
    );
