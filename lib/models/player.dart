import 'package:quiver_hashcode/hashcode.dart';

class Player {
  String key;
  String uid;
  String name;
  int leagueBalance;

  Player({this.key, this.uid, this.name, this.leagueBalance = 0});

  Player.fromFirebaseDynamic(dynamic firebase)
      : key = firebase["key"],
        uid = firebase["uid"],
        name = firebase["name"],
        leagueBalance = firebase["leagueBalance"];

  Map<String, dynamic> toJson() {
    return {
      "key": key,
      "uid": uid,
      "name": name,
      "leagueBalance": leagueBalance,
    };
  }

  @override
  bool operator ==(other) =>
      other is Player && key == other.key && uid == other.uid && name == other
          .name && leagueBalance == other.leagueBalance;

  @override
  int get hashCode => hash4(key, uid, name, leagueBalance);


}
