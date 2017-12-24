class Player {
  String key;
  String uid;
  String name;

  Player({this.key, this.uid, this.name});

  Player.fromFirebaseDynamic(dynamic firebase)
      : key = firebase["key"],
        uid = firebase["uid"],
        name = firebase["name"];

  dynamic toJson() {
    return {
      "key": key,
      "uid": uid,
      "name": name,
    };
  }
}
