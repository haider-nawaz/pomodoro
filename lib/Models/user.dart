import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class User {
  User({
    required this.username,
    required this.firstTimeUser,
    required this.totalPomos,
    required this.todaysPomos,
    required this.longestStreak,
    required this.netFocusHours,
    required this.todayFocusHours,
  });
  @HiveField(0)
  String username;

  @HiveField(1)
  bool firstTimeUser;

  @HiveField(2)
  int totalPomos;

  @HiveField(3)
  int todaysPomos;

  @HiveField(4)
  int longestStreak;

  @HiveField(5)
  int netFocusHours;

  @HiveField(6)
  int todayFocusHours;

  @override
  String toString() {
    return 'Person{username: $username, firstTimeUser: $firstTimeUser, totalPomos: $totalPomos, todaysPomos: $todaysPomos, longestStreak: $longestStreak, netFocusHours: $netFocusHours, todayFocusHours: $todayFocusHours}';
  }
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final typeId = 1;

  @override
  User read(BinaryReader reader) {
    return User(
      username: reader.readString(),
      firstTimeUser: reader.readBool(),
      totalPomos: reader.readInt(),
      todaysPomos: reader.readInt(),
      longestStreak: reader.readInt(),
      netFocusHours: reader.readInt(),
      todayFocusHours: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeString(obj.username);
    writer.writeBool(obj.firstTimeUser);
    writer.writeInt(obj.totalPomos);
    writer.writeInt(obj.todaysPomos);
    writer.writeInt(obj.longestStreak);
    writer.writeInt(obj.netFocusHours);
    writer.writeInt(obj.todayFocusHours);
  }
}



// class User {
//   String? username;
//   bool? firstTimeUser;
//   int? totalPomos;
//   int? todaysPomos;
//   int? longestStreak;
//   int? netFocusHours;
//   int? todayFocusHours;

//   User({
//     this.username,
//     this.firstTimeUser,
//     this.totalPomos,
//     this.todaysPomos,
//     this.longestStreak,
//     this.netFocusHours,
//     this.todayFocusHours,
//   });

//   //return a single instance that I can use throughout the app
//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       username: json['username'],
//       firstTimeUser: json['firstTimeUser'],
//       totalPomos: json['totalPomos'],
//       todaysPomos: json['todaysPomos'],
//       longestStreak: json['longestStreak'],
//       netFocusHours: json['netFocusHours'],
//       todayFocusHours: json['todayFocusHours'],
//     );
//   }
// }
