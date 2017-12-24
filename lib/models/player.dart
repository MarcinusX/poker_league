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

  dynamic toJson() {
    return {
      "key": key,
      "uid": uid,
      "name": name,
      "leagueBalance": leagueBalance,
    };
  }
}
