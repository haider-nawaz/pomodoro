// class FocusSession {
//   DateTime? startTime;
//   DateTime? endTime;
//   String? focusSessionName;
//   int? focusSessionDurationMin;
//   bool? isFocusSessionCompleted;

// }

import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class FocusSession {
  FocusSession({
    required this.startTime,
    required this.endTime,
    required this.focusSessionName,
    required this.focusSessionDurationMin,
    required this.isFocusSessionCompleted,
  });
  @HiveField(0)
  String? startTime;

  @HiveField(1)
  String? endTime;

  @HiveField(2)
  String? focusSessionName;

  @HiveField(3)
  int? focusSessionDurationMin;

  @HiveField(4)
  bool? isFocusSessionCompleted;

  @override
  String toString() {
    return 'FocusSession{startTime: $startTime, endTime: $endTime, focusSessionName: $focusSessionName, focusSessionDurationMin: $focusSessionDurationMin, isFocusSessionCompleted: $isFocusSessionCompleted}';
  }
}

class FocusSessionAdapter extends TypeAdapter<FocusSession> {
  @override
  final typeId = 2;

  @override
  FocusSession read(BinaryReader reader) {
    return FocusSession(
      startTime: reader.readString(),
      endTime: reader.readString(),
      focusSessionName: reader.readString(),
      focusSessionDurationMin: reader.readInt(),
      isFocusSessionCompleted: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, FocusSession obj) {
    writer.writeString(obj.startTime!);
    writer.writeString(obj.endTime!);
    writer.writeString(obj.focusSessionName!);
    writer.writeInt(obj.focusSessionDurationMin ?? 0);
    writer.writeBool(obj.isFocusSessionCompleted ?? false);
  }
}
