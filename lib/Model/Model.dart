import 'dart:convert';

Model modelFromJson(String str) => Model.fromJson(json.decode(str));

String modelToJson(Model data) => json.encode(data.toJson());

class Model {
  String ? label;
  String ? dateTime;
  bool check;
  String ? when;
  int ? id;
  int ? milliseconds;

  String? title;
  String? location;
  String? memo;
  String? notificationSound;
  String? notificationImage;
  List<String>? repeatDays;

  // コンストラクタの定義
  // required -> null 不可
  Model({
    required this.label,
    required this.dateTime,
    required this.check,
    required this.when,
    required this.id,
    required this.milliseconds,
    required this.title,
    required this.location,
    this.memo,
    this.notificationSound = 'デフォルト1',
    this.notificationImage = 'なし',
    this.repeatDays,
  });

  // 通常のコンストラクタより複雑な定義ができる
  factory Model.fromJson(Map<String, dynamic> json) => Model(
    label: json["label"],
    dateTime: json["dateTime"],
    check: json["check"],
    when: json["when"],
    id:json["id"],
    milliseconds:json["milliseconds"],
    title: json["title"],
    location: json["location"],
    memo: json["memo"],
    notificationSound: json["notificationSound"] ?? 'デフォルト1',
    notificationImage: json["notificationImage"] ?? 'なし',
    repeatDays: json["repeatDays"] != null
        ? List<String>.from(json["repeatDays"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "label": label,
    "dateTime": dateTime,
    "check": check,
    "when": when,
    "id":id,
    "milliseconds":milliseconds,
    "title": title,
    "location": location,
    "memo": memo,
    "notificationSound": notificationSound,
    "notificationImage": notificationImage,
    "repeatDays": repeatDays,
  };

  // 繰り返し日の文字列表現を取得するヘルパーメソッド
  String getRepeatDescription() {
    if (repeatDays == null || repeatDays!.isEmpty) {
      return 'なし';
    }
    if (repeatDays!.length == 7) {
      return '毎日';
    }
    return '毎週 ${repeatDays!.join('・')}';
  }
}

